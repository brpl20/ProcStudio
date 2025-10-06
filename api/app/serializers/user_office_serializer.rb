# frozen_string_literal: true

class UserOfficeSerializer
  include JSONAPI::Serializer

  attributes :user_id, :office_id, :partnership_type, :partnership_percentage, 
             :is_administrator, :entry_date

  attribute :compensations do |object|
    object.compensations.order(effective_date: :desc).map do |compensation|
      UserSocietyCompensationSerializer.new(compensation).serializable_hash[:data][:attributes]
    end
  end

  # Include user information for convenience
  attribute :user_name do |object|
    object.user.user_profile&.name || object.user.email
  end

  attribute :user_email do |object|
    object.user.email
  end
end