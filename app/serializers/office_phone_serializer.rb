# frozen_string_literal: true

class OfficePhoneSerializer
  include JSONAPI::Serializer
  attributes :office_id, :phone_id
end
