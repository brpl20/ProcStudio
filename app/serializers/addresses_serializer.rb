# frozen_string_literal: true

class AddressesSerializer
  include JSONAPI::Serializer
  attributes :city, :zip_code, :street, :number, :neighbordhood, :city, :state
end
