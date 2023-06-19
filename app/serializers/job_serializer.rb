# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment

  has_many :works, serializer: WorkSerializer
end
