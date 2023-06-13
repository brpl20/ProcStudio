# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment
end
