# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_infos
#
#  id               :bigint(8)        not null, primary key
#  contactable_type :string           not null
#  contactable_id   :bigint(8)        not null
#  contact_type     :string           not null
#  contact_data     :json             not null
#  is_primary       :boolean          default(FALSE)
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ContactInfo < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :contactable, polymorphic: true
  
  validates :contact_type, presence: true, 
            inclusion: { in: %w[address email phone bank_account] }
  validates :contact_data, presence: true
  
  scope :addresses, -> { where(contact_type: 'address') }
  scope :emails, -> { where(contact_type: 'email') }
  scope :phones, -> { where(contact_type: 'phone') }
  scope :bank_accounts, -> { where(contact_type: 'bank_account') }
  scope :primary, -> { where(is_primary: true) }
  
  before_save :ensure_single_primary_per_type
  
  def address?
    contact_type == 'address'
  end
  
  def email?
    contact_type == 'email'
  end
  
  def phone?
    contact_type == 'phone'
  end
  
  def bank_account?
    contact_type == 'bank_account'
  end
  
  def display_value
    case contact_type
    when 'address'
      address_display
    when 'email'
      contact_data['email'] || contact_data['address']
    when 'phone'
      contact_data['phone_number'] || contact_data['number']
    when 'bank_account'
      bank_account_display
    else
      contact_data.to_s
    end
  end
  
  private
  
  def ensure_single_primary_per_type
    return unless is_primary && is_primary_changed?
    
    # Remove primary flag from other contacts of same type for same contactable
    self.class.where(
      contactable: contactable,
      contact_type: contact_type,
      is_primary: true
    ).where.not(id: id).update_all(is_primary: false)
  end
  
  def address_display
    parts = []
    data = contact_data
    
    if data['street'].present?
      street_part = data['street']
      street_part += ", #{data['number']}" if data['number'].present?
      parts << street_part
    end
    
    parts << data['neighborhood'] if data['neighborhood'].present?
    parts << data['city'] if data['city'].present?
    parts << data['state'] if data['state'].present?
    parts << data['zip_code'] if data['zip_code'].present?
    
    parts.join(', ')
  end
  
  def bank_account_display
    parts = []
    data = contact_data
    
    parts << data['bank_name'] if data['bank_name'].present?
    
    if data['agency'].present? && data['account'].present?
      account_part = "Ag: #{data['agency']}, Cc: #{data['account']}"
      account_part += "/#{data['operation']}" if data['operation'].present?
      parts << account_part
    end
    
    parts << "PIX: #{data['pix']}" if data['pix'].present?
    
    parts.join(' | ')
  end
end
