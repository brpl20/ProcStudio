# File: app/models/phone.rb
# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id             :bigint           not null, primary key
#  deleted_at     :datetime
#  phone_number   :string
#  phoneable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  phoneable_id   :bigint
#
# Indexes
#
#  index_phones_on_deleted_at  (deleted_at)
#  index_phones_on_phoneable   (phoneable_type,phoneable_id)
#

class Phone < ApplicationRecord
  # Soft delete support (if you're using paranoia gem)
  acts_as_paranoid if defined?(Paranoia)

  # Polymorphic association
  belongs_to :phoneable, polymorphic: true

  # Validations
  validates :phone_number, presence: true,
                           format: { with: /\A\+?[\d\s\-\(\)]+\z/ }

  # Normalize phone number before saving
  before_save :normalize_phone_number

  # Scopes for querying
  scope :for_offices, -> { where(phoneable_type: 'Office') }
  # scope :for_companies, -> { where(phoneable_type: 'Company') }
  scope :for_customers, -> { where(phoneable_type: 'ProfileCustomer') }
  scope :mobile, -> { where('phone_number LIKE ?', '%9%') } # Brazilian mobile pattern
  scope :landline, -> { where.not('phone_number LIKE ?', '%9%') }

  # Instance methods
  def formatted_number
    # Brazilian phone formatting
    clean = phone_number.gsub(/\D/, '')

    case clean.length
    when 10 # (11) 1234-5678
      "(#{clean[0..1]}) #{clean[2..5]}-#{clean[6..9]}"
    when 11 # (11) 91234-5678
      "(#{clean[0..1]}) #{clean[2..6]}-#{clean[7..10]}"
    else
      phone_number # Return as-is if doesn't match expected patterns
    end
  end

  def mobile?
    # Brazilian mobile numbers have 9 as the first digit after area code
    clean = phone_number.gsub(/\D/, '')
    clean.length == 11 && clean[2] == '9'
  end

  def phone_type
    mobile? ? 'mobile' : 'landline'
  end

  def whatsapp_link
    clean = phone_number.gsub(/\D/, '')
    clean = "55#{clean}" unless clean.start_with?('55') # Add Brazil country code
    "https://wa.me/#{clean}"
  end

  private

  def normalize_phone_number
    # Remove all non-numeric characters for storage
    self.phone_number = phone_number.gsub(/\D/, '') if phone_number.present?
  end
end
