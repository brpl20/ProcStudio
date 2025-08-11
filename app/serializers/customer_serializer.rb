# frozen_string_literal: true

class CustomerSerializer
  include JSONAPI::Serializer
  attributes :access_email, :created_by_id, :confirmed_at, :profile_type, :profile_id, :status

  attribute :confirmed, &:confirmed?

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :profile_data do |customer|
    if customer.profile
      customer.full_details[:entity]
    else
      nil
    end
  end

  attribute :name do |customer|
    customer.profile&.name || 'N/A'
  end

  attribute :last_name do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.last_name
    else
      nil
    end
  end

  attribute :customer_type do |customer|
    case customer.profile_type
    when 'IndividualEntity'
      'physical_person'
    when 'LegalEntity'
      'legal_person'
    else
      'unknown'
    end
  end

  attribute :cpf do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.cpf
    else
      nil
    end
  end

  attribute :cnpj do |customer|
    if customer.profile.is_a?(LegalEntity)
      customer.profile.cnpj
    else
      nil
    end
  end

  attribute :rg do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.rg
    else
      nil
    end
  end

  attribute :addresses do |customer|
    customer.profile&.addresses&.map do |address|
      {
        street: address.street,
        number: address.number,
        neighborhood: address.neighborhood,
        city: address.city,
        state: address.state,
        zip_code: address.zip_code,
        description: address.complement
      }
    end || []
  end

  attribute :phones do |customer|
    customer.profile&.phones&.map do |phone|
      {
        phone_number: phone.number
      }
    end || []
  end

  attribute :emails do |customer|
    customer.profile&.emails&.map do |email|
      {
        email: email.address
      }
    end || []
  end

  attribute :bank_accounts do |customer|
    customer.profile&.bank_accounts&.map do |bank|
      {
        id: bank.id.to_s,
        account: bank.account_number,
        agency: bank.agency,
        bank_name: bank.bank_name,
        operation: bank.operation,
        pix: bank.pix_key,
        type_account: bank.account_type
      }
    end || []
  end

  attribute :birth do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.birth
    else
      nil
    end
  end

  attribute :gender do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.gender
    else
      nil
    end
  end

  attribute :nationality do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.nationality
    else
      nil
    end
  end

  attribute :civil_status do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.civil_status
    else
      nil
    end
  end

  attribute :capacity do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.capacity
    else
      nil
    end
  end

  attribute :mother_name do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.mother_name
    else
      nil
    end
  end

  attribute :profession do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.profession
    else
      nil
    end
  end

  attribute :nit do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.nit
    else
      nil
    end
  end

  attribute :inss_password do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.inss_password
    else
      nil
    end
  end

  attribute :number_benefit do |customer|
    if customer.profile.is_a?(IndividualEntity)
      customer.profile.number_benefit
    else
      nil
    end
  end

  attribute :represent do |customer|
    # TODO: Implement representative logic if needed
    nil
  end
end
