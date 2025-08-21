# frozen_string_literal: true

# == Schema Information
#
# Table name: law_areas
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(TRUE), not null
#  code               :string           not null
#  description        :text
#  name               :string           not null
#  sort_order         :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_team_id :bigint
#  parent_area_id     :bigint
#
# Indexes
#
#  index_law_areas_on_active              (active)
#  index_law_areas_on_created_by_team_id  (created_by_team_id)
#  index_law_areas_on_parent_area_id      (parent_area_id)
#  index_law_areas_unique_code            (code,created_by_team_id,parent_area_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_team_id => teams.id)
#  fk_rails_...  (parent_area_id => law_areas.id)
#
class LawArea < ApplicationRecord
  # Relacionamento hierárquico
  belongs_to :parent_area, class_name: 'LawArea', optional: true
  has_many :sub_areas, class_name: 'LawArea', foreign_key: 'parent_area_id', dependent: :destroy,
                       inverse_of: :parent_area

  # Relacionamento com team e powers
  belongs_to :created_by_team, class_name: 'Team', optional: true
  has_many :powers, dependent: :restrict_with_error

  # Validações
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: [:created_by_team_id, :parent_area_id] }
  validate :cannot_be_parent_of_itself

  # Scopes
  scope :active, -> { where(active: true) }
  scope :main_areas, -> { where(parent_area_id: nil) }
  scope :sub_areas, -> { where.not(parent_area_id: nil) }
  scope :system_areas, -> { where(created_by_team_id: nil) }
  scope :custom_areas, -> { where.not(created_by_team_id: nil) }
  scope :ordered, -> { order(:sort_order, :name) }

  # Métodos helper
  def main_area?
    parent_area_id.nil?
  end

  def sub_area?
    parent_area_id.present?
  end

  def system_area?
    created_by_team_id.nil?
  end

  def custom_area?
    created_by_team_id.present?
  end

  def full_name
    return name if main_area?

    "#{parent_area.name} - #{name}"
  end

  def hierarchy_path
    return [self] if main_area?

    parent_area.hierarchy_path + [self]
  end

  def depth
    return 0 if main_area?

    parent_area.depth + 1
  end

  # Busca todas as subáreas recursivamente
  def all_sub_areas
    sub_areas.includes(:sub_areas).flat_map { |sub| [sub] + sub.all_sub_areas }
  end

  # Busca todos os poderes aplicáveis (próprios + herdados)
  def applicable_powers
    if main_area?
      powers
    else
      # Poderes específicos da subárea + poderes da área pai que não têm versão específica
      specific_powers = powers
      parent_descriptions = specific_powers.pluck(:description, :category)

      inherited_powers = parent_area.powers.where.not(
        [:description, :category] => parent_descriptions
      )

      Power.where(id: (specific_powers + inherited_powers).map(&:id))
    end
  end

  private

  def cannot_be_parent_of_itself
    return unless parent_area_id

    if id == parent_area_id
      errors.add(:parent_area, 'não pode ser a própria área')
    elsif parent_area&.hierarchy_path&.include?(self)
      errors.add(:parent_area, 'criaria uma referência circular')
    end
  end
end
