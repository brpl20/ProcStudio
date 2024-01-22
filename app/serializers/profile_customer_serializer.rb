# frozen_string_literal: true

class ProfileCustomerSerializer
  include JSONAPI::Serializer
  attributes :customer_id, :customer_type, :name, :last_name, :cpf, :cnpj,
             :emails

  attributes :addresses, :bank_accounts, :birth, :capacity, :civil_status,
             :company, :customer_id, :emails, :gender, :inss_password,
             :mother_name, :nationality, :nit, :number_benefit, :phones,
             :profession, :rg, :status, :represent, :accountant_id, if: proc { |_, options| options[:action] == 'show' }

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
        created_at: document.created_at,
        updated_at: document.updated_at,
        url: document.document_docx&.url
      }
    end
  end
end
