# frozen_string_literal: true

class WorkEventSerializer
  include JSONAPI::Serializer
  attributes :date, :description, :work_id
end
