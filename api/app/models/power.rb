# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id                 :bigint           not null, primary key
#  category           :integer          not null
#  description        :string           not null
#  is_base            :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_team_id :bigint
#  law_area_id        :bigint
#
# Indexes
#
#  index_powers_on_category_and_law_area_id  (category,law_area_id)
#  index_powers_on_created_by_team_id        (created_by_team_id)
#  index_powers_on_is_base                   (is_base)
#  index_powers_on_law_area_id               (law_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_team_id => teams.id)
#  fk_rails_...  (law_area_id => law_areas.id)
#

class Power < ApplicationRecord
  enum :category, {
    # Três procedimentos principais
    administrative: 0,    # Administrativo
    judicial: 1,          # Judicial
    extrajudicial: 2      # Extrajudicial
  }

  # Relacionamentos
  belongs_to :law_area, optional: true
  belongs_to :created_by_team, class_name: 'Team', optional: true

  validates :description, presence: true
  validates :category, presence: true
  validates :law_area, presence: true, if: :specific_power?

  # Scopes para diferentes tipos de poderes
  scope :base_powers, -> { where(is_base: true) }
  scope :specific_powers, -> { where(is_base: false).where.not(law_area_id: nil) }
  scope :custom_powers, -> { where.not(created_by_team_id: nil) }
  scope :system_powers, -> { where(created_by_team_id: nil) }

  # Scopes por procedimento
  scope :administrative_powers, -> { where(category: :administrative) }
  scope :judicial_powers, -> { where(category: :judicial) }
  scope :extrajudicial_powers, -> { where(category: :extrajudicial) }

  # Métodos helper
  def base_power?
    is_base?
  end

  def specific_power?
    !is_base? && law_area_id.present?
  end

  def custom_power?
    created_by_team_id.present?
  end

  def system_power?
    created_by_team_id.nil?
  end

  def full_description
    if specific_power? && law_area
      "#{category.humanize} (#{law_area.full_name}) - #{description}"
    else
      "#{category.humanize} - #{description}"
    end
  end

  # Métodos para herança de poderes
  def self.for_area(area)
    return all if area.nil?

    # Se é área principal, retorna poderes base + específicos da área
    if area.main_area?
      base_powers.where(category: category).or(where(law_area: area))
    else
      # Se é subárea, busca poderes específicos da subárea primeiro
      specific_powers = where(law_area: area)

      # Depois busca poderes da área pai que não têm versão específica na subárea
      parent_descriptions = specific_powers.pluck(:description, :category)
      inherited_powers = where(law_area: area.parent_area)
                           .where.not([:description, :category] => parent_descriptions)

      # Combine poderes base + específicos + herdados
      base_for_category = base_powers

      where(id: (base_for_category + specific_powers + inherited_powers).map(&:id).uniq)
    end
  end

  def applicable_to_area?(target_area)
    return true if law_area.nil? && is_base? # Poderes base se aplicam a tudo
    return true if law_area == target_area

    # Se o poder é da área pai, é aplicável às subáreas
    return true if target_area&.sub_area? && law_area == target_area.parent_area

    false
  end
end
