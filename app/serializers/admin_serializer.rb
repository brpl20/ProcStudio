# frozen_string_literal: true

class AdminSerializer
  include JSONAPI::Serializer
  attributes :email

  has_one :profile_admin, serializer: ProfileAdminSerializer
end
