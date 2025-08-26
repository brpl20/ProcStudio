# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    user
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    cpf { Faker::Number.number(digits: 11).to_s }
    rg { Faker::Number.number(digits: 9).to_s }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { ['male', 'female'].sample }
    civil_status { ['single', 'married', 'divorced', 'widowed'].sample }
    nationality { 'brazilian' }
    mother_name { "#{Faker::Name.female_first_name} #{Faker::Name.last_name}" }
    oab { Faker::Number.number(digits: 6).to_s }
    role { ['admin', 'lawyer', 'secretary', 'intern'].sample }
    status { 'active' }

    trait :admin do
      role { 'admin' }
    end

    trait :lawyer do
      role { 'lawyer' }
    end

    trait :secretary do
      role { 'secretary' }
    end

    trait :intern do
      role { 'intern' }
    end
  end
end
