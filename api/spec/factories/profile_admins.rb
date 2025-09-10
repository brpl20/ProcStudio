# frozen_string_literal: true

FactoryBot.define do
  factory :profile_admin do
    role { 'lawyer' }
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    gender { 'male' }
    oab { Faker::Number.number(digits: 6) }
    rg { Faker::Number.number(digits: 6) }
    cpf { Faker::Number.number(digits: 11) }
    nationality { 'brazilian' }
    civil_status { 'single' }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    mother_name { Faker::Name.name }
    status { 'active' }
    origin { 'something' }
    admin
    office
  end
end
