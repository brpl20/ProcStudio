# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment,
             :profile_admin_id, :customer_id

  has_many :works, serializer: WorkSerializer
end
