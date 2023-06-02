# frozen_string_literal: true

class ProfileAdminSerializer
  include JSONAPI::Serializer
  attributes :role, :status, :admin_id, :office_id, :name, :last_name, :gender, :oab,
             :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :office_id

  has_many :addresses, serializer: AddressSerializer

  has_many :phones, serializer: PhoneSerializer

  has_many :emails, serializer: EmailSerializer

  has_many :bank_accounts, serializer: BankAccountSerializer
end
