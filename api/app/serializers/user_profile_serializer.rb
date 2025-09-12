# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :bigint           not null, primary key
#  birth        :date
#  civil_status :string
#  cpf          :string
#  deleted_at   :datetime
#  gender       :string
#  last_name    :string
#  mother_name  :string
#  name         :string
#  nationality  :string
#  oab          :string
#  origin       :string
#  rg           :string
#  role         :string
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  office_id    :bigint
#  user_id      :bigint           not null
#
# Indexes
#
#  index_user_profiles_on_deleted_at  (deleted_at)
#  index_user_profiles_on_office_id   (office_id)
#  index_user_profiles_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#
class UserProfileSerializer
  include JSONAPI::Serializer

  attributes :role, :name, :last_name, :status

  attribute :access_email do |object|
    object.user.email
  end

  attributes :user_id, :office_id, :gender, :oab, :rg, :cpf,
             :nationality, :origin, :civil_status, :birth, :mother_name

  attribute :deleted do |object|
    object.deleted_at.present?
  end

  attribute :bank_accounts do |object|
    bank_accounts = object.bank_accounts
    bank_accounts&.map { |bank_account| BankAccountSerializer.new(bank_account).serializable_hash[:data][:attributes] }
  end

  attribute :phones do |object|
    phones = object.phones
    phones&.map { |phone| PhoneSerializer.new(phone).serializable_hash[:data][:attributes] }
  end

  attribute :addresses do |object|
    addresses = object.addresses
    addresses&.map { |address| AddressSerializer.new(address).serializable_hash[:data][:attributes] }
  end

  attribute :avatar_url do |object|
    object.avatar_url(only_path: false)
  end
end
