# frozen_string_literal: true

class BankAccountSerializer
  include JSONAPI::Serializer
  attributes :id, :bank_name, :type_account, :agency, :account, :operation
end
