# frozen_string_literal: true

class RepresentSerializer
  include JSONAPI::Serializer

  attributes :id, :profile_customer_id, :representor_id
end
