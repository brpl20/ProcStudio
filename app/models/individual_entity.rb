# frozen_string_literal: true

# == Schema Information
#
# Table name: individual_entities
#
#  id                   :bigint(8)        not null, primary key
#  name                 :string           not null
#  last_name            :string
#  gender               :string
#  rg                   :string
#  cpf                  :string           not null
#  nationality          :string
#  civil_status         :string
#  profession           :string
#  birth                :date
#  mother_name          :string
#  nit                  :string
#  inss_password        :string
#  invalid_person       :boolean          default(FALSE)
#  additional_documents :json
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  capacity             :string           default("able")
#  number_benefit       :string
#
class IndividualEntity < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  has_many :profile_admins, dependent: :nullify
  has_many :profile_customers, dependent: :nullify
  has_many :legal_entities_as_representative, class_name: 'LegalEntity',
           foreign_key: 'legal_representative_id'
  
  # Law office relationships
  has_many :legal_entity_office_relationships, foreign_key: :lawyer_id, dependent: :destroy
  has_many :legal_entity_offices, through: :legal_entity_office_relationships
  
  # Polymorphic association for Customer
  has_many :customers, as: :profile, dependent: :nullify
  
  # Polymorphic contact system
  include Contactable
  
  # Nested attributes for contact system
  accepts_nested_attributes_for :contact_addresses, :contact_phones, 
                                :contact_emails, :contact_bank_accounts, 
                                reject_if: :all_blank, allow_destroy: true
  
  enum capacity: {
    able: 'able',                      # Capaz
    relatively: 'relatively',          # Relativamente Incapaz  
    absolutely: 'absolutely'           # Absolutamente Incapaz
  }

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true
  validates :gender, inclusion: { in: %w[M F O], allow_blank: true }
  validates :civil_status, inclusion: { 
    in: %w[single married divorced widowed separated], allow_blank: true 
  }
  validates :capacity, presence: true
  
  scope :by_cpf, ->(cpf) { where(cpf: cpf) }
  scope :by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
  
  def full_name
    [name, last_name].compact.join(' ')
  end
  
  def age
    return nil unless birth
    
    today = Date.current
    age = today.year - birth.year
    age -= 1 if today < birth + age.years
    age
  end
  
  # Contact info methods are now provided by Contactable concern
  
  # Law office specific methods
  def law_offices
    legal_entity_offices.includes(:legal_entity)
  end
  
  def is_lawyer?
    legal_entity_office_relationships.any?
  end
  
  def partnerships
    legal_entity_office_relationships.includes(:legal_entity_office)
  end
  
  def partner_offices
    legal_entity_office_relationships.partners.includes(legal_entity_office: :legal_entity)
  end
end
