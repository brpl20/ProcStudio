# File: app/models/address.rb
# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  address_type     :string           default("main")
#  addressable_type :string           not null
#  city             :string           not null
#  complement       :string
#  deleted_at       :datetime
#  neighborhood     :string
#  number           :string
#  state            :string           not null
#  street           :string           not null
#  zip_code         :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :bigint           not null
#
# Indexes
#
#  index_addresses_on_addressable     (addressable_type,addressable_id)
#  index_addresses_on_city_and_state  (city,state)
#  index_addresses_on_deleted_at      (deleted_at)
#  index_addresses_on_zip_code        (zip_code)
#

class Address < ApplicationRecord
  # Soft delete support
  acts_as_paranoid if defined?(Paranoia)
  
  # Polymorphic association
  belongs_to :addressable, polymorphic: true
  
  # Enums for address types
  enum :address_type, {
    main: 'main',
    secondary: 'secondary', 
    billing: 'billing',
    correspondence: 'correspondence'
  }, default: 'main'
  
  # Validations
  validates :zip_code, :street, :city, :state, presence: true
  validates :zip_code, format: { 
    with: /\A\d{5}-?\d{3}\z/, 
    message: "Invalid CEP format (use: 12345-678)" 
  }
  validates :state, inclusion: { 
    in: %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO],
    message: "Invalid Brazilian state" 
  }
  
  # Normalize CEP before saving
  before_save :normalize_zip_code
  
  # Scopes
  scope :by_state, ->(state) { where(state: state.upcase) }
  scope :by_city, ->(city) { where('LOWER(city) = ?', city.downcase) }
  scope :main_addresses, -> { where(address_type: 'main') }
  scope :billing_addresses, -> { where(address_type: 'billing') }
  
  # Instance methods
  def full_address
    parts = [
      "#{street}#{", #{number}" if number.present?}",
      complement,
      neighborhood,
      "#{city}/#{state}",
      formatted_zip_code
    ].compact.reject(&:blank?)
    
    parts.join(' - ')
  end
  
  def formatted_zip_code
    return zip_code unless zip_code.present?
    clean = zip_code.gsub(/\D/, '')
    "#{clean[0..4]}-#{clean[5..7]}"
  end
  
  def google_maps_url
    encoded_address = URI.encode_www_form_component(full_address)
    "https://www.google.com/maps/search/?api=1&query=#{encoded_address}"
  end
  
  def same_city_as?(other_address)
    return false unless other_address.is_a?(Address)
    
    city.downcase == other_address.city.downcase && 
    state.upcase == other_address.state.upcase
  end
  
  private
  
  def normalize_zip_code
    self.zip_code = zip_code.gsub(/\D/, '') if zip_code.present?
  end
end

# ## ADDRESS

# # frozen_string_literal: true

# # == Schema Information
# #
# # Table name: addresses
# #
# #  id           :bigint           not null, primary key
# #  city         :string
# #  description  :string
# #  neighborhood :string
# #  number       :integer
# #  state        :string
# #  street       :string
# #  zip_code     :string
# #  created_at   :datetime         not null
# #  updated_at   :datetime         not null
# #

# class Address < ApplicationRecord
#   has_many :admin_addresses, dependent: :destroy
#   has_many :profile_admins, through: :admin_addresses

#   with_options presence: true do
#     validates :zip_code
#     validates :street
#     validates :city
#     validates :state
#   end
# end
