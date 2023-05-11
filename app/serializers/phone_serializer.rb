# frozen_string_literal: true

class PhoneSerializer
  include JSONAPI::Serializer
  attributes :id, :phone_number
end
