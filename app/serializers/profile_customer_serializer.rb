# frozen_string_literal: true

class ProfileCustomerSerializer
  include JSONAPI::Serializer
  attributes :customer_id, :customer_type, :name, :last_name, :cpf, :cnpj,
             :emails

  attributes :status, :customer_id, :rg, :birth, :gender,
             :civil_status, :nationality, :capacity, :profession, :company,
             :number_benefit, :nit, :mother_name, :addresses, :phones, :emails,
             :bank_accounts, if: proc { |_, options| options[:action] == 'show' }

  attribute :default_phone do |object|
    object.phones.first&.phone_number
  end

  attribute :default_email do |object|
    object.emails.first&.email
  end

  attribute :city do |object|
    object.addresses.first&.city
  end

end
