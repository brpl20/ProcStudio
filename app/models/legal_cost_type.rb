# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_cost_types
#
#  id            :bigint           not null, primary key
#  active        :boolean          default(TRUE)
#  category      :string
#  description   :text
#  display_order :integer
#  is_system     :boolean          default(FALSE), not null
#  key           :string           not null
#  metadata      :jsonb
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  team_id       :bigint
#
# Indexes
#
#  index_legal_cost_types_on_active           (active)
#  index_legal_cost_types_on_category         (category)
#  index_legal_cost_types_on_display_order    (display_order)
#  index_legal_cost_types_on_is_system        (is_system)
#  index_legal_cost_types_on_key_and_team_id  (key,team_id) UNIQUE
#  index_legal_cost_types_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class LegalCostType < ApplicationRecord
  belongs_to :team, optional: true
  has_many :legal_cost_entries, dependent: :restrict_with_error

  validates :key, presence: true,
                  uniqueness: { scope: :team_id }
  validates :name, presence: true
  validates :is_system, inclusion: { in: [true, false] }

  validate :system_entries_must_not_have_team
  validate :cannot_modify_system_entry

  scope :active, -> { where(active: true) }
  scope :system_types, -> { where(is_system: true, team_id: nil) }
  scope :custom_types, ->(team) { where(team: team, is_system: false) }
  scope :available_for, ->(team) { where(team_id: [nil, team.id]).active }
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered, -> { order(:display_order, :name) }

  CATEGORIES = ['judicial', 'administrative', 'notarial', 'tax', 'other'].freeze

  before_validation :set_defaults
  before_destroy :prevent_system_deletion

  def system?
    is_system
  end

  def custom?
    !is_system
  end

  def editable?
    !system?
  end

  def deletable?
    !system? && legal_cost_entries.empty?
  end

  def display_name
    "#{name}#{' (Sistema)' if system?}"
  end

  private

  def set_defaults
    self.display_order ||= 999
    self.category ||= 'other'
  end

  def system_entries_must_not_have_team
    errors.add(:team_id, 'deve ser nulo para entradas do sistema') if is_system && team_id.present?
  end

  def cannot_modify_system_entry
    return unless persisted? && is_system_was && !is_system

    errors.add(:is_system, 'não pode ser alterado depois de criado')
  end

  def prevent_system_deletion
    throw(:abort) if system?
  end
end
