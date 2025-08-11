# == Schema Information
#
# Table name: legal_entity_office_relationships
#
#  id                     :bigint(8)        not null, primary key
#  legal_entity_office_id :bigint(8)        not null
#  lawyer_id              :bigint(8)        not null
#  partnership_type       :string
#  ownership_percentage   :decimal(5, 2)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class LegalEntityOfficeRelationship < ApplicationRecord
  belongs_to :legal_entity_office
  belongs_to :lawyer, class_name: 'IndividualEntity'
  
  validates :legal_entity_office_id, presence: true
  validates :lawyer_id, presence: true, uniqueness: { scope: :legal_entity_office_id }
  validates :partnership_type, inclusion: { 
    in: %w[socio associado socio_de_servico],
    message: "%{value} is not a valid partnership type"
  }, allow_blank: true
  validates :ownership_percentage, 
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    allow_nil: true
  
  scope :partners, -> { where(partnership_type: 'socio') }
  scope :associates, -> { where(partnership_type: 'associado') }
  scope :service_partners, -> { where(partnership_type: 'socio_de_servico') }
  scope :with_ownership, -> { where.not(ownership_percentage: [nil, 0]) }
  
  def partner?
    partnership_type == 'socio'
  end
  
  def associate?
    partnership_type == 'associado'
  end
  
  def service_partner?
    partnership_type == 'socio_de_servico'
  end
  
  def ownership_description
    return "No ownership" if ownership_percentage.nil? || ownership_percentage.zero?
    "#{ownership_percentage}% ownership"
  end
end

