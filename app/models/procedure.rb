# frozen_string_literal: true

# == Schema Information
#
# Table name: procedures
#
#  id               :bigint           not null, primary key
#  ancestry         :string
#  city             :string
#  claim_value      :decimal(15, 2)
#  competence       :string
#  conciliation     :boolean          default(FALSE)
#  conviction_value :decimal(15, 2)
#  deleted_at       :datetime
#  end_date         :date
#  justice_free     :boolean          default(FALSE)
#  notes            :text
#  number           :string
#  priority         :boolean          default(FALSE)
#  priority_type    :string
#  procedure_class  :string
#  procedure_type   :string           not null
#  received_value   :decimal(15, 2)
#  responsible      :string
#  start_date       :date
#  state            :string
#  status           :string           default("in_progress")
#  system           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  law_area_id      :bigint
#  work_id          :bigint           not null
#
# Indexes
#
#  index_procedures_on_ancestry                    (ancestry)
#  index_procedures_on_competence                  (competence)
#  index_procedures_on_deleted_at                  (deleted_at)
#  index_procedures_on_law_area_id                 (law_area_id)
#  index_procedures_on_number                      (number)
#  index_procedures_on_procedure_type              (procedure_type)
#  index_procedures_on_status                      (status)
#  index_procedures_on_system                      (system)
#  index_procedures_on_work_id                     (work_id)
#  index_procedures_on_work_id_and_procedure_type  (work_id,procedure_type)
#
# Foreign Keys
#
#  fk_rails_...  (law_area_id => law_areas.id)
#  fk_rails_...  (work_id => works.id)
#
class Procedure < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # For hierarchical tree structure
  # NOTE: If you get "undefined method has_ancestry", restart Rails server after bundle install
  # The ancestry gem needs to be loaded properly
  has_ancestry if defined?(Ancestry)

  # Associations
  belongs_to :work
  belongs_to :law_area, optional: true

  has_many :procedural_parties, dependent: :destroy
  has_many :plaintiffs, -> { where(party_type: 'plaintiff') }, class_name: 'ProceduralParty'
  has_many :defendants, -> { where(party_type: 'defendant') }, class_name: 'ProceduralParty'

  has_many :honoraries, dependent: :destroy
  # Documents and work_events would need procedure_id added to their tables
  # has_many :documents, dependent: :destroy
  # has_many :work_events, dependent: :destroy

  # Enums
  enum :procedure_type, {
    administrative: 'administrativo',
    judicial: 'judicial',
    extrajudicial: 'extrajudicial'
  }, prefix: true

  enum :status, {
    in_progress: 'in_progress',
    paused: 'paused',
    completed: 'completed',
    archived: 'archived'
  }, prefix: true

  # Available systems for procedures
  SYSTEMS = [
    'INSS',
    'Eproc',
    'Projudi',
    'ECAC',
    'Incra',
    'PJe',
    'ESAJ',
    'Outro'
  ].freeze

  # Available competences
  COMPETENCES = [
    'Justiça Federal',
    'Justiça do Trabalho',
    'Justiça Estadual',
    'INSS',
    'Receita Federal',
    'Incra',
    'Ministério Público',
    'Defensoria Pública',
    'Outro'
  ].freeze

  # Priority types
  PRIORITY_TYPES = [
    'age',          # Idade avançada
    'sickness',     # Doença grave
    'disability',   # Deficiência
    'maternity',    # Maternidade
    'other'
  ].freeze

  # Validations
  validates :procedure_type, presence: true
  validates :status, presence: true
  validates :system, inclusion: { in: SYSTEMS }, allow_blank: true
  validates :competence, inclusion: { in: COMPETENCES }, allow_blank: true
  validates :priority_type, inclusion: { in: PRIORITY_TYPES }, allow_blank: true, if: :priority?
  validates :claim_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :conviction_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :received_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_validation :set_defaults

  # Scopes
  scope :active, -> { where(status: ['in_progress', 'paused']) }
  scope :completed, -> { where(status: 'completed') }
  scope :archived, -> { where(status: 'archived') }
  scope :with_priority, -> { where(priority: true) }
  scope :judicial, -> { where(procedure_type: 'judicial') }
  scope :administrative, -> { where(procedure_type: 'administrativo') }
  scope :extrajudicial, -> { where(procedure_type: 'extrajudicial') }
  # Ancestry scopes - only if ancestry is available
  if defined?(Ancestry)
    scope :root_procedures, -> { roots }
    scope :child_procedures_of, ->(procedure) { children_of(procedure) }
  else
    scope :root_procedures, -> { where(ancestry: nil) }
    scope :child_procedures_of, ->(procedure) { where(ancestry: procedure.id.to_s) }
  end

  # Nested attributes
  accepts_nested_attributes_for :procedural_parties, allow_destroy: true
  accepts_nested_attributes_for :honoraries, allow_destroy: true

  # Instance methods
  def display_name
    "#{procedure_type.humanize} - #{number || 'Sem número'}"
  end

  def location
    return nil unless city.present? || state.present?

    [city, state].compact.join(' - ')
  end

  def has_financial_values?
    claim_value.present? || conviction_value.present? || received_value.present?
  end

  def financial_summary
    {
      claim: claim_value || 0,
      conviction: conviction_value || 0,
      received: received_value || 0,
      pending: (conviction_value || 0) - (received_value || 0)
    }
  end

  def add_plaintiff(partyable_or_name, **attributes)
    build_party('plaintiff', partyable_or_name, attributes)
  end

  def add_defendant(partyable_or_name, **attributes)
    build_party('defendant', partyable_or_name, attributes)
  end

  def primary_plaintiff
    plaintiffs.find_by(is_primary: true) || plaintiffs.first
  end

  def primary_defendant
    defendants.find_by(is_primary: true) || defendants.first
  end

  def has_children?
    if respond_to?(:children)
      children.any?
    else
      Procedure.where(ancestry: id.to_s).any?
    end
  end

  def root_procedure
    if respond_to?(:root?)
      root? ? self : root
    else
      ancestry.nil? ? self : Procedure.find_by(id: ancestry.split('/').first)
    end
  end

  def all_descendants
    if respond_to?(:descendants)
      descendants
    else
      Procedure.where('ancestry LIKE ?', "#{id}/%")
    end
  end

  # Create a child procedure
  def create_child_procedure(attributes = {})
    if respond_to?(:children)
      children.create(attributes.merge(work: work))
    else
      Procedure.create(attributes.merge(work: work, ancestry: id.to_s))
    end
  end

  private

  def set_defaults
    self.status ||= 'in_progress'
  end

  def build_party(party_type, partyable_or_name, attributes)
    party_attributes = attributes.merge(party_type: party_type)

    if partyable_or_name.is_a?(String)
      party_attributes[:name] = partyable_or_name
    else
      party_attributes[:partyable] = partyable_or_name
    end

    procedural_parties.create!(party_attributes)
  end
end
