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
class AddressSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :zip_code, :number, :neighborhood, :city, :state, :street
end
