# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer
  attributes :description, :deadline, :status, :priority, :comment 

  attribute :customer do |object|
    "#{object.profile_customer.name} #{object.profile_customer.last_name}"
  end

  attribute :responsible do |object|
    object.profile_admin.name
  end

  attribute :work_number do |object|
    object.work.number
  end

  attributes :profile_admin_id, :profile_customer, :work, if: proc { |_, options| options[:action] == 'show' }
end
