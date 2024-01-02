# frozen_string_literal: true

class OfficeSerializer
  include JSONAPI::Serializer
  attributes :name, :cnpj, :city, :site, :responsible_lawyer_id

  attributes :oab, :society, :foundation, :cep, :street, :number, :neighborhood,
             :state, :profile_admins, :phones, :emails, :bank_accounts, :works,
             if: proc { |_, options| options[:action] == 'show' }

  attribute :office_type_description do |object|
    object.office_type.description
  end
end
