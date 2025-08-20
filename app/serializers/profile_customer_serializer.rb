# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id             :bigint           not null, primary key
#  birth          :date
#  capacity       :string
#  civil_status   :string
#  cnpj           :string
#  company        :string
#  cpf            :string
#  customer_type  :string
#  deleted_at     :datetime
#  document       :json
#  gender         :string
#  inss_password  :string
#  invalid_person :integer
#  last_name      :string
#  mother_name    :string
#  name           :string
#  nationality    :string
#  nit            :string
#  number_benefit :string
#  profession     :string
#  rg             :string
#  status         :string           default("active"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accountant_id  :integer
#  created_by_id  :bigint
#  customer_id    :bigint           not null
#
# Indexes
#
#  index_profile_customers_on_accountant_id  (accountant_id)
#  index_profile_customers_on_created_by_id  (created_by_id)
#  index_profile_customers_on_customer_id    (customer_id)
#  index_profile_customers_on_deleted_at     (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (customer_id => customers.id)
#
class ProfileCustomerSerializer
  include JSONAPI::Serializer

  attribute :access_email do |object|
    object.customer.email
  end

  attributes :customer_id, :customer_type, :name, :last_name, :cpf, :cnpj,
             :emails

  attributes :birth, :capacity, :civil_status,
             :company, :customer_id, :gender, :inss_password,
             :mother_name, :nationality, :nit, :number_benefit,
             :profession, :rg, :status, :accountant_id,
             :created_by_id, if: proc { |_, options| options[:action] == 'show' }

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
        url: document.file&.url
      }
    end
  end

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :represent_by do |object|
    represent = object.represent

    if represent
      {
        profile_customer_id: represent.representor_id
      }
    end
  end

  attribute :represents do |object|
    object.represented_customers.map do |represent|
      profile_customer = represent.profile_customer

      {
        access_email: profile_customer.customer.email,
        customer_id: profile_customer.customer_id,
        customer_type: profile_customer.customer_type,
        name: profile_customer.name,
        last_name: profile_customer.last_name,
        cpf: profile_customer.cpf,
        cnpj: profile_customer.cnpj,
        company: profile_customer.company,
        nit: profile_customer.nit,
        number_benefit: profile_customer.number_benefit,
        profession: profile_customer.profession,
        rg: profile_customer.rg,
        status: profile_customer.status
      }
    end
  end

  attribute :phones do |object|
    phones = object.phones

    phones&.map { |phone| PhoneSerializer.new(phone).serializable_hash[:data][:attributes] }
  end

  attribute :addresses do |object|
    addresses = object.addresses

    addresses&.map { |address| AddressSerializer.new(address).serializable_hash[:data][:attributes] }
  end

  attribute :emails do |object|
    emails = object.emails

    emails&.map { |email| EmailSerializer.new(email).serializable_hash[:data][:attributes] }
  end

  attribute :bank_accounts do |object|
    bank_accounts = object.bank_accounts

    bank_accounts&.map { |email| BankAccountSerializer.new(email).serializable_hash[:data][:attributes] }
  end
end
