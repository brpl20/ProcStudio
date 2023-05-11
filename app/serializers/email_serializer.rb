# frozen_string_literal: true

class EmailSerializer
  include JSONAPI::Serializer
  attributes :id, :email
end
