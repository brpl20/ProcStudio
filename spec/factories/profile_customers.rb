# frozen_string_literal: true

FactoryBot.define do
  factory :profile_customer do
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    customer_type { 'Representative' }
    gender { 'other' }
    rg { Faker::Number.number(digits: 6) }
    cpf { Faker::Number.number(digits: 11) }
    cnpj { Faker::Number.number(digits: 14) }
    nationality { 'brazilian' }
    civil_status { 'married' }
    capacity { 'able' }
    profession { Faker::Company.profession }
    company { Faker::Company.name }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    mother_name { Faker::Name.name }
    number_benefit { Faker::Number.number(digits: 5) }
    status { 'active' }
    document { '' }
    nit { Faker::Number.number(digits: 5) }
    inss_password { Faker::Number.number(digits: 5) }
    invalid_person { 1 }
    customer
  end
end
