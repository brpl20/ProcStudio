# frozen_string_literal: true

class OfficeSerializer
  include JSONAPI::Serializer
  attributes :name, :cnpj, :oab, :society, :foundation, :site, :cep, :street,
             :number, :neighborhood, :city, :state, :office_type_id

  has_many :office_phones, serializer: OfficePhoneSerializer

  has_many :office_emails, serializer: OfficeEmailSerializer

  has_many :office_bank_accounts, serializer: OfficeBankAccountSerializer

  has_many :works, serializer: WorkSerializer
end
