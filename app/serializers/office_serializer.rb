# frozen_string_literal: true

class OfficeSerializer
  include JSONAPI::Serializer

  attributes :name, :cnpj, :city, :site, :responsible_lawyer_id

  attributes :oab, :society, :foundation, :zip_code, :street, :number, :neighborhood,
             :state, :profile_admins, :phones, :emails, :bank_accounts, :works,
             :accounting_type, if: proc { |_, options| options[:action] == 'show' }

  attribute :office_type_description do |object|
    object.office_type.description
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end
end
