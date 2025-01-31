# frozen_string_literal: true

class AddressSerializer
  include JSONAPI::Serializer
  attributes :id, :description, :zip_code, :number, :neighborhood, :city, :state, :street
end
