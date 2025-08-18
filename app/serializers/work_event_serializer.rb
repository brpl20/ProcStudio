# frozen_string_literal: true

class WorkEventSerializer
  include JSONAPI::Serializer

  attributes :date, :description, :work_id

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
