# frozen_string_literal: true

module Contactable
  extend ActiveSupport::Concern

  included do
    # New polymorphic contact associations
    has_many :contact_addresses, as: :contactable, dependent: :destroy
    has_many :contact_phones, as: :contactable, dependent: :destroy
    has_many :contact_emails, as: :contactable, dependent: :destroy
    has_many :contact_bank_accounts, as: :contactable, dependent: :destroy
    
    # Convenient aliases that match the old naming convention
    alias_method :addresses, :contact_addresses
    alias_method :phones, :contact_phones
    alias_method :emails, :contact_emails
    alias_method :bank_accounts, :contact_bank_accounts
  end

  # Primary contact helper methods
  def primary_address
    contact_addresses.primary.first
  end

  def primary_phone
    contact_phones.primary.first
  end

  def primary_email
    contact_emails.primary.first
  end

  def primary_bank_account
    contact_bank_accounts.primary.first
  end

  # Formatted primary contact information
  def primary_phone_number
    primary_phone&.formatted_number
  end

  def primary_email_address
    primary_email&.address
  end

  def primary_address_text
    primary_address&.full_address
  end

  def primary_bank_info
    primary_bank_account&.display_name
  end

  # Contact existence checks
  def has_address?
    contact_addresses.any?
  end

  def has_phone?
    contact_phones.any?
  end

  def has_email?
    contact_emails.any?
  end

  def has_bank_account?
    contact_bank_accounts.any?
  end

  # WhatsApp helper
  def whatsapp_phones
    contact_phones.whatsapp
  end

  def primary_whatsapp
    whatsapp_phones.primary.first || whatsapp_phones.first
  end

  def whatsapp_link
    primary_whatsapp&.whatsapp_link
  end

  # Contact summary for display
  def contact_summary
    {
      addresses: contact_addresses.count,
      phones: contact_phones.count,
      emails: contact_emails.count,
      bank_accounts: contact_bank_accounts.count,
      primary_phone: primary_phone_number,
      primary_email: primary_email_address,
      has_whatsapp: whatsapp_phones.any?
    }
  end
end