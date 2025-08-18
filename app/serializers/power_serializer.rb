# frozen_string_literal: true

class PowerSerializer
  include JSONAPI::Serializer

  attributes :id, :description, :category
end
