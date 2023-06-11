# frozen_string_literal: true

class ChecklistSerializer
  include JSONAPI::Serializer
  attributes :description
end
