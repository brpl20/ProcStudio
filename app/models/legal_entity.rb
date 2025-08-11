# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_entities
#
#  id                      :bigint(8)        not null, primary key
#  name                    :string           not null
#  cnpj                    :string
#  state_registration      :string
#  number_of_partners      :integer
#  status                  :string           default("active")
#  accounting_type         :string
#  entity_type             :string
#  legal_representative_id :bigint(8)
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class LegalEntity < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :legal_representative, class_name: 'IndividualEntity', optional: true
  has_many :profile_admins, dependent: :nullify
  has_many :profile_customers, dependent: :nullify
  
  # New associations for law office functionality
  has_one :legal_entity_office, dependent: :destroy
  has_many :legal_entity_office_relationships, through: :legal_entity_office
  has_many :lawyers, through: :legal_entity_office_relationships, source: :lawyer, class_name: 'IndividualEntity'
  
  # Polymorphic association for Customer
  has_many :customers, as: :profile, dependent: :nullify
  
  # Polymorphic contact system
  include Contactable
  
  validates :name, presence: true
  validates :cnpj, uniqueness: true, allow_blank: true
  validates :entity_type, inclusion: { 
    in: %w[law_firm company office], allow_blank: true 
  }
  validates :status, inclusion: { 
    in: %w[active inactive suspended] 
  }
  validates :accounting_type, inclusion: { 
    in: %w[simples_nacional lucro_presumido lucro_real], allow_blank: true 
  }
  
  scope :active, -> { where(status: 'active') }
  scope :by_entity_type, ->(type) { where(entity_type: type) }
  scope :by_cnpj, ->(cnpj) { where(cnpj: cnpj) }
  scope :law_firms, -> { where(entity_type: 'law_firm') }
  scope :companies, -> { where(entity_type: 'company') }
  scope :offices, -> { where(entity_type: 'office') }
  
  def display_name
    name
  end
  
  def representative_name
    legal_representative&.full_name
  end
  
  # Contact info methods are now provided by Contactable concern
  
  def law_firm?
    entity_type == 'law_firm'
  end
  
  def company?
    entity_type == 'company'
  end
  
  def office?
    entity_type == 'office'
  end
  
  # Law office specific methods
  def is_law_office?
    legal_entity_office.present?
  end
  
  def office_oab_id
    legal_entity_office&.oab_id
  end
  
  def office_partners
    legal_entity_office&.partners || []
  end
  
  def office_associates
    legal_entity_office&.associates || []
  end
end
