# frozen_string_literal: true

class ProfileCustomerSerializer
  include JSONAPI::Serializer
  attributes :name, :customer_type, :status, :customer_id,
             :last_name, :cpf, :rg, :birth, :gender, :cnpj, :civil_status,
             :nationality, :capacity, :profession, :company, :number_benefit, :nit, :mother_name

  has_many :addresses, through: :customer_addresses

  has_many :phones, serializer: PhoneSerializer

  has_many :emails, through: :customer_emails

  has_many :bank_accounts, through: :customer_bank_accounts
end
