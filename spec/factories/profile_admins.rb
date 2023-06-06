# frozen_string_literal: true

FactoryBot.define do
  factory :profile_admin do
    role { 1 }
    name { 'John' }
    last_name { 'Doe' }
    gender { 1 }
    oab { '123456' }
    rg { '12345678' }
    cpf { '12345678901' }
    nationality { 'Brazilian' }
    civil_status { 1 }
    birth { '1980-01-01' }
    mother_name { 'Jane' }
    status { 1 }
    admin
    office
  end
end
