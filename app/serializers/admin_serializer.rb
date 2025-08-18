# frozen_string_literal: true

class AdminSerializer
  include JSONAPI::Serializer

  attributes :access_email, :status

  has_one :profile_admin, serializer: ProfileAdminSerializer

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
