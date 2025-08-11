# == Schema Information
#
# Table name: contact_addresses
#
#  id               :bigint(8)        not null, primary key
#  contactable_type :string           not null
#  contactable_id   :bigint(8)        not null
#  street           :string
#  number           :string
#  complement       :string
#  neighborhood     :string
#  city             :string
#  state            :string
#  zip_code         :string
#  country          :string
#  is_primary       :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ContactAddress < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, format: { with: /\A\d{8}\z/, message: "deve conter 8 dígitos" }
  validates :number, presence: true
  
  scope :primary, -> { where(is_primary: true) }
  
  before_save :ensure_single_primary_per_contactable
  before_save :format_zip_code
  
  def full_address
    parts = [
      "#{street}, #{number}",
      complement.present? ? complement : nil,
      neighborhood,
      "#{city} - #{state}",
      "CEP: #{formatted_zip_code}"
    ].compact
    
    parts.join("\n")
  end
  
  def formatted_zip_code
    return zip_code unless zip_code&.match?(/^\d{8}$/)
    zip_code.gsub(/(\d{5})(\d{3})/, '\1-\2')
  end
  
  private
  
  def ensure_single_primary_per_contactable
    return unless is_primary && is_primary_changed?
    
    ContactAddress.where(contactable: contactable, is_primary: true)
                  .where.not(id: id)
                  .update_all(is_primary: false)
  end
  
  def format_zip_code
    self.zip_code = zip_code.to_s.gsub(/\D/, '') if zip_code.present?
  end
end
