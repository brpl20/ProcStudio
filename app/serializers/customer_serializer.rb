# frozen_string_literal: true

class CustomerSerializer
  include JSONAPI::Serializer
  attributes :email, :created_by_id, :confirmed_at, :profile_customer_id

  attribute :confirmed, &:confirmed?
end
