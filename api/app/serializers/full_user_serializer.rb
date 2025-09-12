# frozen_string_literal: true

class FullUserSerializer
  include JSONAPI::Serializer

  # User attributes
  attributes :email, :status, :created_at, :updated_at

  # Team information
  attribute :team do |object|
    if object.team
      {
        id: object.team.id,
        name: object.team.name,
        subdomain: object.team.subdomain
      }
    end
  end

  # User Profile information (embedded)
  attribute :profile do |object|
    profile = object.user_profile
    if profile
      {
        id: profile.id,
        name: profile.name,
        last_name: profile.last_name,
        full_name: profile.full_name,
        role: profile.role,
        status: profile.status,
        gender: profile.gender,
        oab: profile.oab,
        rg: profile.rg,
        cpf: profile.cpf,
        nationality: profile.nationality,
        origin: profile.origin,
        civil_status: profile.civil_status,
        birth: profile.birth,
        mother_name: profile.mother_name,
        avatar_url: profile.try(:avatar_url, only_path: false),
        created_at: profile.created_at,
        updated_at: profile.updated_at
      }
    end
  end

  # Office information
  attribute :office do |object|
    office = object.user_profile&.office
    if office
      {
        id: office.id,
        name: office.name,
        cnpj: office.cnpj,
        oab_inscricao: office.oab_inscricao,
        society: office.society,
        accounting_type: office.accounting_type
      }
    end
  end

  # User offices (for lawyers who belong to multiple offices)
  attribute :offices do |object|
    if object.respond_to?(:offices)
      object.offices.map do |office|
        user_office = object.user_offices.find_by(office: office)
        {
          id: office.id,
          name: office.name,
          cnpj: office.cnpj,
          partnership_type: user_office&.partnership_type,
          partnership_percentage: user_office&.partnership_percentage,
          entry_date: user_office&.entry_date
        }
      end
    else
      []
    end
  end

  # Phones
  attribute :phones do |object|
    profile = object.user_profile
    if profile && profile.respond_to?(:phones)
      profile.phones.map do |phone|
      {
        id: phone.id,
        phone_number: phone.phone_number,
        phone_type: phone.try(:phone_type)
      }
      end
    else
      []
    end
  end

  # Addresses
  attribute :addresses do |object|
    profile = object.user_profile
    if profile && profile.respond_to?(:addresses)
      profile.addresses.map do |address|
      {
        id: address.id,
        street: address.street,
        number: address.number,
        complement: address.complement,
        neighborhood: address.neighborhood,
        city: address.city,
        state: address.state,
        zip_code: address.zip_code,
        address_type: address.try(:address_type)
      }
      end
    else
      []
    end
  end

  # Bank accounts
  attribute :bank_accounts do |object|
    profile = object.user_profile
    if profile && profile.respond_to?(:bank_accounts)
      profile.bank_accounts.map do |account|
      {
        id: account.id,
        bank_name: account.bank_name,
        type_account: account.type_account,
        agency: account.agency,
        account: account.account,
        operation: account.operation,
        pix: account.pix
      }
      end
    else
      []
    end
  end

  # Works associated (count only for performance)
  attribute :works_count do |object|
    profile = object.user_profile
    if profile && profile.respond_to?(:works)
      profile.works.count
    else
      0
    end
  end

  # Jobs associated (count only for performance)
  attribute :jobs_count do |object|
    profile = object.user_profile
    if profile && profile.respond_to?(:jobs)
      profile.jobs.count
    else
      0
    end
  end

  # Deletion status
  attribute :deleted do |object|
    object.deleted_at.present?
  end
end