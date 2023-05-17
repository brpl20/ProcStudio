# frozen_string_literal: true

class CustomersSerializer
  include JSONAPI::Serializer
  attributes :email
end
