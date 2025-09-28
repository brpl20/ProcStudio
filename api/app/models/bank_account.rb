# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id            :bigint           not null, primary key
#  account       :string
#  account_type  :string           default("checking")
#  agency        :string
#  bank_name     :string
#  bankable_type :string
#  deleted_at    :datetime
#  operation     :string
#  pix           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bankable_id   :bigint
#
# Indexes
#
#  index_bank_accounts_on_bankable    (bankable_type,bankable_id)
#  index_bank_accounts_on_deleted_at  (deleted_at)
#

class BankAccount < ApplicationRecord
  # Soft delete support (if you're using paranoia gem)
  acts_as_paranoid if defined?(Paranoia)

  # Polymorphic association
  belongs_to :bankable, polymorphic: true

  # Explicitly declare string attribute for enum (Rails 7.2+ requirement)
  attribute :account_type, :string, default: 'checking'

  # Enum for account type
  enum :account_type, {
    checking: 'checking',      # Conta Corrente
    savings: 'savings',        # Conta Poupança
    salary: 'salary',          # Conta Salário
    investment: 'investment'   # Conta Investimento
  }, default: 'checking'

  # Validations
  validates :bank_name, :agency, :account, presence: true
  validates :agency, format: {
    with: /\A\d{1,6}(-?\d)?\z/,
    message: I18n.t('errors.messages.invalid_agency_format')
  }
  validates :account, format: {
    with: /\A\d{1,15}(-?\d)?\z/,
    message: I18n.t('errors.messages.invalid_account_format')
  }

  # Normalize data before saving
  before_save :normalize_bank_data

  # Scopes for querying
  scope :for_offices, -> { where(bankable_type: 'Office') }
  scope :for_customers, -> { where(bankable_type: 'ProfileCustomer') }
  scope :for_users, -> { where(bankable_type: 'UserProfile') }
  scope :checking_accounts, -> { where(account_type: 'checking') }
  scope :with_pix, -> { where.not(pix: [nil, '']) }

  # Instance methods
  def formatted_agency
    return agency if agency.blank?

    clean = agency.gsub(/\D/, '')
    if clean.length > 4
      "#{clean[0..-2]}-#{clean[-1]}"
    else
      clean
    end
  end

  def formatted_account
    return account if account.blank?

    clean = account.gsub(/\D/, '')
    if clean.length > 1
      "#{clean[0..-2]}-#{clean[-1]}"
    else
      clean
    end
  end

  def full_account_info
    parts = []
    parts << bank_name.to_s if bank_name.present?
    parts << "Ag: #{formatted_agency}" if agency.present?
    parts << "Conta: #{formatted_account}" if account.present?
    parts << "Op: #{operation}" if operation.present?

    parts.join(' | ')
  end

  def pix_type
    return nil if pix.blank?

    case pix
    when /\A\d{11}\z/
      :cpf
    when /\A\d{14}\z/
      :cnpj
    when /\A[\w._%+-]+@[\w.-]+\.[A-Z]{2,}\z/i
      :email
    when /\A\+?[\d\s\-\(\)]+\z/
      :phone
    when /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      :random_key
    else
      :unknown
    end
  end

  def formatted_pix
    return pix if pix.blank?

    case pix_type
    when :cpf
      pix.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
    when :cnpj
      pix.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '\1.\2.\3/\4-\5')
    when :phone
      clean = pix.gsub(/\D/, '')
      if clean.length == 11
        "(#{clean[0..1]}) #{clean[2..6]}-#{clean[7..10]}"
      else
        pix
      end
    else
      pix
    end
  end

  private

  def normalize_bank_data
    normalize_account_fields
    normalize_pix_key
  end

  def normalize_account_fields
    self.agency = agency.gsub(/\D/, '') if agency.present?
    self.account = account.gsub(/\D/, '') if account.present?
  end

  def normalize_pix_key
    return if pix.blank?

    self.pix = pix.strip
    normalize_cpf_cnpj_pix
    normalize_email_pix
  end

  def normalize_cpf_cnpj_pix
    self.pix = pix.gsub(/\D/, '') if %r{^[\d\.\-/]+$}.match?(pix)
  end

  def normalize_email_pix
    self.pix = pix.downcase if pix.include?('@')
  end
end
