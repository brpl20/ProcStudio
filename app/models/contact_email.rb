# == Schema Information
#
# Table name: contact_emails
#
#  id               :bigint(8)        not null, primary key
#  contactable_type :string           not null
#  contactable_id   :bigint(8)        not null
#  address          :string
#  email_type       :string
#  is_primary       :boolean
#  is_verified      :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ContactEmail < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  validates :address, presence: true, format: { 
    with: URI::MailTo::EMAIL_REGEXP, 
    message: "deve ser um email válido" 
  }
  validates :email_type, inclusion: { 
    in: %w[personal work billing support marketing],
    allow_blank: true 
  }
  
  scope :primary, -> { where(is_primary: true) }
  scope :verified, -> { where(is_verified: true) }
  scope :personal, -> { where(email_type: 'personal') }
  scope :work, -> { where(email_type: 'work') }
  
  before_save :ensure_single_primary_per_contactable
  before_save :normalize_email
  
  def domain
    address.split('@').last if address.present?
  end
  
  def display_name
    case email_type
    when 'personal'
      'Pessoal'
    when 'work'
      'Trabalho'
    when 'billing'
      'Financeiro'
    when 'support'
      'Suporte'
    when 'marketing'
      'Marketing'
    else
      email_type&.humanize
    end
  end
  
  private
  
  def ensure_single_primary_per_contactable
    return unless is_primary && is_primary_changed?
    
    ContactEmail.where(contactable: contactable, is_primary: true)
                .where.not(id: id)
                .update_all(is_primary: false)
  end
  
  def normalize_email
    self.address = address.to_s.downcase.strip if address.present?
  end
end
