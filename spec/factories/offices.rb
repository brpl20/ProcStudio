# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    name { Faker::Company.name }
    cnpj { Faker::Number.number(digits: 14) }
    oab { Faker::Number.number(digits: 6) }
    society { 'company' }
    accounting_type { 'simple' }
    foundation { Faker::Date.birthday(min_age: 18, max_age: 65) }
    site { Faker::Internet.url }
    cep { Faker::Address.postcode }
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
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'factories', 'images', 'Ruby.jpg'), 'image/jpg') }
  end

  factory :office_with_lawyers do
    after(:create) do |office|
      create_list(:profile_admin, 2, office: office)
    end
  end
end
