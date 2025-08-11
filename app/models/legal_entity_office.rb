# == Schema Information
#
# Table name: legal_entity_offices
#
#  id                 :bigint(8)        not null, primary key
#  legal_entity_id    :bigint(8)        not null
#  oab_id             :string
#  inscription_number :string
#  society_link       :string
#  legal_specialty    :string
#  team_id            :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class LegalEntityOffice < ApplicationRecord
  belongs_to :legal_entity
  belongs_to :team, optional: true
  has_many :legal_entity_office_relationships, dependent: :destroy
  has_many :lawyers, through: :legal_entity_office_relationships, source: :lawyer

  validates :legal_entity_id, presence: true, uniqueness: true
  validates :oab_id, uniqueness: { allow_blank: true }
  
  scope :with_oab, -> { where.not(oab_id: [nil, ""]) }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  
  def partners
    legal_entity_office_relationships.where(partnership_type: 'socio')
  end
  
  def associates
    legal_entity_office_relationships.where(partnership_type: 'associado')
  end
  
  def service_partners
    legal_entity_office_relationships.where(partnership_type: 'socio_de_servico')
  end
  
  def total_ownership_percentage
    legal_entity_office_relationships.sum(:ownership_percentage)
  end
  
  def add_lawyer(lawyer, partnership_type: 'associado', ownership_percentage: 0)
    legal_entity_office_relationships.create!(
      lawyer: lawyer,
      partnership_type: partnership_type,
      ownership_percentage: ownership_percentage
    )
  end
end

