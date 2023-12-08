# frozen_string_literal: true

class DocumentSerializer
  include JSONAPI::Serializer
  attributes :document_type, :work_id
end
