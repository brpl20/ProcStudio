# == Schema Information
#
# Table name: contact_phones
#
#  id               :bigint(8)        not null, primary key
#  contactable_type :string           not null
#  contactable_id   :bigint(8)        not null
#  number           :string
#  phone_type       :string
#  is_primary       :boolean
#  is_whatsapp      :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ContactPhone < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  validates :number, presence: true, format: { 
    with: /\A\d{10,11}\z/, 
    message: "deve conter 10 ou 11 dígitos" 
  }
  validates :phone_type, inclusion: { 
    in: %w[mobile landline commercial fax whatsapp],
    allow_blank: true 
  }
  
  scope :primary, -> { where(is_primary: true) }
  scope :mobile, -> { where(phone_type: 'mobile') }
  scope :whatsapp, -> { where(is_whatsapp: true) }
  scope :commercial, -> { where(phone_type: 'commercial') }
  
  before_save :ensure_single_primary_per_contactable
  before_save :format_phone_number
  before_save :set_whatsapp_for_mobile
  
  def formatted_number
    return number unless number&.match?(/^\d{10,11}$/)
    
    if number.length == 11
      number.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      number.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    end
  end
  
  def mobile?
    phone_type == 'mobile' || number&.length == 11
  end
  
  def whatsapp_link
    return nil unless is_whatsapp && number.present?
    "https://wa.me/55#{number}"
  end
  
  private
  
  def ensure_single_primary_per_contactable
    return unless is_primary && is_primary_changed?
    
    ContactPhone.where(contactable: contactable, is_primary: true)
                .where.not(id: id)
                .update_all(is_primary: false)
  end
  
  def format_phone_number
    self.number = number.to_s.gsub(/\D/, '') if number.present?
  end
  
  def set_whatsapp_for_mobile
    self.is_whatsapp = true if phone_type == 'whatsapp'
  end
end
