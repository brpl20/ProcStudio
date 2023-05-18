# frozen_string_literal: true

class CustomerSerializer
  include JSONAPI::Serializer
  attributes :email
end
