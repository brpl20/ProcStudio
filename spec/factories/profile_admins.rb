# frozen_string_literal: true

FactoryBot.define do
  factory :profile_admin do
    role { 1 }
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    gender { 1 }
    oab { Faker::Number.number(digits: 6) }
    rg { Faker::Number.number(digits: 6) }
    cpf { Faker::Number.number(digits: 11) }
    nationality { 'Brazilian' }
    civil_status { 1 }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    mother_name { Faker::Name.name }
    status { 1 }
    admin
    office
  end
end
