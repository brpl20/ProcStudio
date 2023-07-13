# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    description { Faker::Address.community }
    zip_code { Faker::Address.zip_code }
    street { Faker::Address.street_name }
    number { Faker::Number.number(digits: 5) }
    neighborhood { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
  end
end
