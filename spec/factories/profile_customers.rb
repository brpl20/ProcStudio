# frozen_string_literal: true

FactoryBot.define do
  factory :profile_customer do
    role { 1 }
    name { 'MyString' }
    lastname { 'MyString' }
    gender { 1 }
    rg { 'MyString' }
    cpf { 'MyString' }
    nationality { 'MyString' }
    civil_status { 1 }
    capacity { 1 }
    profession { 'MyString' }
    company { 'MyString' }
    birth { '2023-03-08' }
    mother_name { 'MyString' }
    number_benefit { 'MyString' }
    status { 1 }
    document { '' }
    nit { 'MyString' }
    inss_password { 'MyString' }
    invalid_person { 1 }
    customer { nil }
  end
end
