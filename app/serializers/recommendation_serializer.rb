# frozen_string_literal: true

class RecommendationSerializer
  include JSONAPI::Serializer
  attributes :percentage, :commission, :profile_customer_id, :work_id
end
