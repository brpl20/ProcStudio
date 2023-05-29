# frozen_string_literal: true

class OfficeEmailSerializer
  include JSONAPI::Serializer
  attributes :office_id, :email_id
end
