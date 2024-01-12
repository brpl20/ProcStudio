# frozen_string_literal: true

class ProfileAdminSerializer
  include JSONAPI::Serializer
  attributes :role, :name, :last_name

  attribute :email do |object|
    object.admin.email
  end

  attributes :status, :admin_id, :office_id, :gender, :oab, :rg, :cpf,
             :nationality, :origin, :civil_status, :birth, :mother_name,
             :office_id, :addresses, :phones, :emails, :bank_accounts,
             if: proc { |_, options| options[:action] == 'show' }
end
