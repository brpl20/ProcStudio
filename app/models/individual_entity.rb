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
#
class IndividualEntity < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  has_many :profile_admins, dependent: :nullify
  has_many :profile_customers, dependent: :nullify
  has_many :legal_entities_as_representative, class_name: 'LegalEntity',
           foreign_key: 'legal_representative_id'
  
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
  validates :cpf, presence: true, uniqueness: true
  validates :gender, inclusion: { in: %w[M F O], allow_blank: true }
  validates :civil_status, inclusion: { 
    in: %w[single married divorced widowed separated], allow_blank: true 
  }
  
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
  
  def primary_email
    emails.primary.first&.display_value
  end
  
  def primary_phone
    phones.primary.first&.display_value
  end
  
  def primary_address
    addresses.primary.first&.display_value
  end
end
