# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    bank_name { Faker::Bank.name }
    type_account { 'corrente' }
    agency { Faker::Bank.account_number }
    account { Faker::Bank.routing_number }
    operation { Faker::Number.number(digits: 3) }
    pix { Faker::Number.number(digits: 11) }
  end
end
