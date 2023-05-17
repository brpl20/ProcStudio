# frozen_string_literal: true

class BankAccountsSerializer
  include JSONAPI::Serializer
  attributes :bank_name, :type_account, :agency, :account, :operation
end
