# frozen_string_literal: true

# == Schema Information
#
# Table name: procedural_parties
#
#  id             :bigint           not null, primary key
#  cpf_cnpj       :string
#  deleted_at     :datetime
#  is_primary     :boolean          default(FALSE)
#  name           :string
#  notes          :text
#  oab_number     :string
#  party_type     :string           not null
#  partyable_type :string
#  position       :integer
#  represented_by :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  partyable_id   :bigint
#  procedure_id   :bigint           not null
#
# Indexes
#
#  index_procedural_parties_on_cpf_cnpj                         (cpf_cnpj)
#  index_procedural_parties_on_deleted_at                       (deleted_at)
#  index_procedural_parties_on_party_type                       (party_type)
#  index_procedural_parties_on_partyable                        (partyable_type,partyable_id)
#  index_procedural_parties_on_partyable_type_and_partyable_id  (partyable_type,partyable_id)
#  index_procedural_parties_on_procedure_id                     (procedure_id)
#  index_procedural_parties_on_procedure_id_and_party_type      (procedure_id,party_type)
#
# Foreign Keys
#
#  fk_rails_...  (procedure_id => procedures.id)
#
class ProceduralParty < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Associations
  belongs_to :procedure
  belongs_to :partyable, polymorphic: true, optional: true

  # Enums
  enum :party_type, {
    plaintiff: 'plaintiff',
    defendant: 'defendant'
  }

  # Validations
  validates :party_type, presence: true
  validates :name, presence: true, if: -> { partyable.blank? }
  validate :partyable_or_name_present
  validate :only_one_primary_per_type

  # Scopes
  scope :plaintiffs, -> { where(party_type: 'plaintiff') }
  scope :defendants, -> { where(party_type: 'defendant') }
  scope :primary, -> { where(is_primary: true) }
  scope :ordered, -> { order(:position, :created_at) }

  # Callbacks
  before_validation :set_defaults
  before_create :set_position

  # Instance methods
  def display_name
    if partyable.present?
      partyable.try(:full_name) || partyable.try(:name) || 'Unknown'
    else
      name
    end
  end

  def identification
    if partyable.present?
      partyable.try(:cpf) || partyable.try(:cnpj) || cpf_cnpj
    else
      cpf_cnpj
    end
  end

  def is_customer?
    partyable_type == 'ProfileCustomer'
  end

  def is_external?
    partyable.blank?
  end

  def party_details
    {
      name: display_name,
      identification: identification,
      oab_number: oab_number,
      represented_by: represented_by,
      is_primary: is_primary,
      is_customer: is_customer?,
      notes: notes
    }
  end

  private

  def set_defaults
    self.is_primary = false if is_primary.nil?
  end

  def set_position
    return if position.present?

    max_position = procedure.procedural_parties
                     .where(party_type: party_type)
                     .maximum(:position) || 0
    self.position = max_position + 1
  end

  def partyable_or_name_present
    return unless partyable.blank? && name.blank?

    errors.add(:base, 'Either a partyable reference or a name must be present')
  end

  def only_one_primary_per_type
    return unless is_primary?

    existing_primary = procedure.procedural_parties
                         .where(party_type: party_type, is_primary: true)
                         .where.not(id: id)
                         .exists?

    return unless existing_primary

    errors.add(:is_primary, "already exists for #{party_type}")
  end
end
