# frozen_string_literal: true

class OfficeBankAccountSerializer
  include JSONAPI::Serializer

  attributes :office_id, :bank_account_id
end
