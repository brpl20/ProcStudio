# frozen_string_literal: true

class ProfileCustomerSerializer
  include JSONAPI::Serializer

  attribute :access_email do |object|
    object.customer.email
  end

  attributes :customer_id, :customer_type, :name, :last_name, :cpf, :cnpj,
             :emails

  attributes :birth, :capacity, :civil_status,
             :company, :customer_id, :gender, :inss_password,
             :mother_name, :nationality, :nit, :number_benefit,
             :profession, :rg, :status, :accountant_id,
             :created_by_id, if: proc { |_, options| options[:action] == 'show' }

  attribute :default_phone do |object|
    object.phones.first&.phone_number
  end

  attribute :default_email do |object|
    object.emails.first&.email
  end

  attribute :city do |object|
    object.addresses.first&.city
  end

  attribute :customer_files do |object|
    object.customer_files.map do |document|
      {
        id: document.id,
        file_description: document.file_description,
        profile_customer_id: document.profile_customer_id,
        url: document.file&.url
      }
    end
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :represent_by do |object|
    represent = object.represent

    if represent
      {
        profile_customer_id: represent.representor_id
      }
    end
  end

  attribute :represents do |object|
    object.represented_customers.map do |represent|
      {
        profile_customer_id: represent.profile_customer_id
      }
    end
  end

  attribute :phones do |object|
    phones = object.phones

    phones&.map { |phone| PhoneSerializer.new(phone).serializable_hash[:data][:attributes] }
  end

  attribute :addresses do |object|
    addresses = object.addresses

    addresses&.map { |address| AddressSerializer.new(address).serializable_hash[:data][:attributes] }
  end

  attribute :emails do |object|
    emails = object.emails

    emails&.map { |email| EmailSerializer.new(email).serializable_hash[:data][:attributes] }
  end

  attribute :bank_accounts do |object|
    bank_accounts = object.bank_accounts

    bank_accounts&.map { |email| BankAccountSerializer.new(email).serializable_hash[:data][:attributes] }
  end
end
