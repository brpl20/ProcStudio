# frozen_string_literal: true

class OfficeSerializer
  include JSONAPI::Serializer
  attributes :name, :cnpj, :oab, :society, :foundation, :site, :cep, :street,
             :number, :neighborhood, :city, :state, :office_type_id, :profile_admins, :phones, :emails, :bank_accounts, :works
end
