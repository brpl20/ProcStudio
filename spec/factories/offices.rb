# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    name { 'Pellizzetti' }
    cnpj { Faker::Number.number(digits: 14) }
    oab { Faker::Number.number(digits: 6) }
    society { 'company' }
    foundation { Faker::Date.birthday(min_age: 18, max_age: 65) }
    site { Faker::Internet.url }
    cep { '79750000' }
    street { 'Rua Um' }
    number { Faker::Number.number(digits: 3) }
    neighborhood { 'centro' }
    city { 'Nova Andradina' }
    state { 'MS' }
    office_type { FactoryBot.create(:office_type) }
    transient do
      profile_admins { [build(:profile_admin)] }
    end
  end
end
