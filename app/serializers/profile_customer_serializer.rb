# frozen_string_literal: true

class ProfileCustomerSerializer
  include JSONAPI::Serializer
  attributes :name, :customer_type, :status, :customer_id,
             :last_name, :cpf, :rg, :birth, :gender, :cnpj, :civil_status,
             :nationality, :capacity, :profession, :company, :number_benefit, :nit, :mother_name

  has_many :addresses, serializer: AddressSerializer

  has_many :phones, serializer: PhoneSerializer

  has_many :emails, serializer: EmailSerializer

  has_many :bank_accounts, serializer: BankAccountSerializer
end
