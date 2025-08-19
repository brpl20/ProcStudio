# frozen_string_literal: true

# == Schema Information
#
# Table name: offices
#
#  id                    :bigint           not null, primary key
#  accounting_type       :string
#  city                  :string
#  cnpj                  :string
#  deleted_at            :datetime
#  foundation            :date
#  name                  :string
#  neighborhood          :string
#  number                :integer
#  oab                   :string
#  site                  :string
#  society               :string
#  state                 :string
#  street                :string
#  zip_code              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  office_type_id        :bigint           not null
#  responsible_lawyer_id :integer
#  team_id               :bigint           not null
#
# Indexes
#
#  index_offices_on_accounting_type        (accounting_type)
#  index_offices_on_deleted_at             (deleted_at)
#  index_offices_on_office_type_id         (office_type_id)
#  index_offices_on_responsible_lawyer_id  (responsible_lawyer_id)
#  index_offices_on_team_id                (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_type_id => office_types.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :office do
    name { Faker::Company.name }
    cnpj { Faker::Number.number(digits: 14) }
    oab { Faker::Number.number(digits: 6) }
    society { 'company' }
    accounting_type { 'simple' }
    foundation { Faker::Date.birthday(min_age: 18, max_age: 65) }
    site { Faker::Internet.url }
    zip_code { Faker::Address.postcode }
    street { Faker::Address.street_name }
    number { Faker::Number.number(digits: 3) }
    neighborhood { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    office_type_id { FactoryBot.create(:office_type).id }
    transient do
      profile_admins { [build(:profile_admin)] }
    end
  end

  trait :office_with_logo do
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec/factories/images/Ruby.jpg'), 'image/jpg') }
  end

  factory :office_with_lawyers do
    after(:create) do |office|
      create_list(:profile_admin, 2, office: office)
    end
  end
end
