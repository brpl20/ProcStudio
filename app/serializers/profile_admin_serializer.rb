# frozen_string_literal: true

class ProfileAdminSerializer
  include JSONAPI::Serializer
  attributes :role, :status, :admin_id, :office_id, :oab, :origin

  attribute :access_email do |object|
    object.admin.email
  end

  # Get personal data from IndividualEntity
  attribute :name do |object|
    object.individual_entity&.name || object.name
  end

  attribute :last_name do |object|
    object.individual_entity&.last_name || object.last_name
  end

  attribute :gender do |object|
    object.individual_entity&.gender || object.gender
  end

  attribute :rg do |object|
    object.individual_entity&.rg || object.rg
  end

  attribute :cpf do |object|
    object.individual_entity&.cpf || object.cpf
  end

  attribute :nationality do |object|
    object.individual_entity&.nationality || object.nationality
  end

  attribute :civil_status do |object|
    object.individual_entity&.civil_status || object.civil_status
  end

  attribute :birth do |object|
    object.individual_entity&.birth || object.birth
  end

  attribute :mother_name do |object|
    object.individual_entity&.mother_name || object.mother_name
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  # Include contact information from IndividualEntity when showing details
  attribute :addresses, if: proc { |_, options| options[:action] == 'show' } do |object|
    object.individual_entity&.addresses&.map do |address|
      {
        id: address.id,
        street: address.street,
        number: address.number,
        complement: address.complement,
        neighborhood: address.neighborhood,
        city: address.city,
        state: address.state,
        zip_code: address.zip_code,
        is_primary: address.is_primary
      }
    end || []
  end
end
