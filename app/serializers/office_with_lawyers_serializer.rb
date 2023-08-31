# frozen_string_literal: true

class OfficeWithLawyersSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :lawyers do |object|
    object.profile_admins.map do |lawyer|
      {
        id: lawyer.id,
        name: lawyer.name
      }
    end
  end
end
