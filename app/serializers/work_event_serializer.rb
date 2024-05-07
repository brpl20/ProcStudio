# frozen_string_literal: true

class WorkEventSerializer
  include JSONAPI::Serializer
  attributes :status, :date, :description, :work_id
end
