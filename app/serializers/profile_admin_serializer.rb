# frozen_string_literal: true

class ProfileAdminSerializer
  include JSONAPI::Serializer
  attributes :role, :name, :last_name

  attribute :access_email do |object|
    object.admin.email
  end

  attributes :status, :admin_id, :office_id, :gender, :oab, :rg, :cpf,
             :nationality, :origin, :civil_status, :birth, :mother_name,
             :office_id, :addresses, :phones, :bank_accounts,
             if: proc { |_, options| options[:action] == 'show' }

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :emails do |object|
    emails = object.emails

    emails&.map { |email| EmailSerializer.new(email).serializable_hash[:data][:attributes] }
  end

  attribute :bank_accounts do |object|
    bank_accounts = object.bank_accounts

    bank_accounts&.map { |email| BankAccountSerializer.new(email).serializable_hash[:data][:attributes] }
  end

  attribute :phones do |object|
    phones = object.phones

    phones&.map { |phone| PhoneSerializer.new(phone).serializable_hash[:data][:attributes] }
  end
end
