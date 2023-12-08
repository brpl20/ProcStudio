# frozen_string_literal: true

class PendingDocumentSerializer
  include JSONAPI::Serializer
  attributes :description, :work_id
end
