# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment,
             :profile_admin_id, :customer_id, :work_id
end
