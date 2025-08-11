# == Schema Information
#
# Table name: contact_bank_accounts
#
#  id               :bigint(8)        not null, primary key
#  contactable_type :string           not null
#  contactable_id   :bigint(8)        not null
#  bank_name        :string
#  bank_code        :string
#  agency           :string
#  account_number   :string
#  account_type     :string
#  pix_key          :string
#  is_primary       :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ContactBankAccount < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  validates :bank_name, presence: true
  validates :bank_code, presence: true, format: { 
    with: /\A\d{3}\z/, 
    message: "deve conter 3 dígitos" 
  }
  validates :agency, presence: true
  validates :account_number, presence: true
  validates :account_type, inclusion: { 
    in: %w[checking savings salary investment],
    allow_blank: true 
  }
  validates :pix_key, format: { 
    with: /\A[\w\.\-@]+\z/, 
    message: "formato inválido",
    allow_blank: true 
  }
  
  scope :primary, -> { where(is_primary: true) }
  scope :checking, -> { where(account_type: 'checking') }
  scope :savings, -> { where(account_type: 'savings') }
  scope :with_pix, -> { where.not(pix_key: [nil, '']) }
  
  before_save :ensure_single_primary_per_contactable
  before_save :format_bank_data
  
  def display_name
    "#{bank_name} - Ag: #{agency} - Conta: #{account_number}"
  end
  
  def account_type_name
    case account_type
    when 'checking'
      'Conta Corrente'
    when 'savings'
      'Poupança'
    when 'salary'
      'Conta Salário'
    when 'investment'
      'Conta Investimento'
    else
      account_type&.humanize
    end
  end
  
  def full_account_info
    info = {
      bank: "#{bank_name} (#{bank_code})",
      agency: agency,
      account: account_number,
      type: account_type_name
    }
    
    info[:pix] = pix_key if pix_key.present?
    info
  end
  
  private
  
  def ensure_single_primary_per_contactable
    return unless is_primary && is_primary_changed?
    
    ContactBankAccount.where(contactable: contactable, is_primary: true)
                      .where.not(id: id)
                      .update_all(is_primary: false)
  end
  
  def format_bank_data
    self.bank_code = bank_code.to_s.gsub(/\D/, '') if bank_code.present?
    self.agency = agency.to_s.gsub(/\D/, '') if agency.present?
    self.pix_key = pix_key.to_s.strip.downcase if pix_key.present?
  end
end
