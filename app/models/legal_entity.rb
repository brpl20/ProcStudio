# frozen_string_literal: true

# == Schema Information
#
# Table name: legal_entities
#
#  id                      :bigint(8)        not null, primary key
#  name                    :string           not null
#  cnpj                    :string
#  inscription_number      :string
#  state_registration      :string
#  oab_id                  :string
#  society_link            :string
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
  
  # Polymorphic contact info
  has_many :contact_infos, as: :contactable, dependent: :destroy
  has_many :addresses, -> { where(contact_type: 'address') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :emails, -> { where(contact_type: 'email') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :phones, -> { where(contact_type: 'phone') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :bank_accounts, -> { where(contact_type: 'bank_account') }, 
           class_name: 'ContactInfo', as: :contactable
  
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
  
  def primary_email
    emails.primary.first&.display_value
  end
  
  def primary_phone
    phones.primary.first&.display_value
  end
  
  def primary_address
    addresses.primary.first&.display_value
  end
  
  def law_firm?
    entity_type == 'law_firm'
  end
  
  def company?
    entity_type == 'company'
  end
  
  def office?
    entity_type == 'office'
  end
end
