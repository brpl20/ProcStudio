# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    name { 'Pellizzetti' }
    cnpj { '12312312312345' }
    oab { '1234566' }
    society { 'company' }
    foundation { '2023-10-10' }
    site { 'www.pellizzetti.com.br' }
    cep { '79750000' }
    street { 'Rua Um' }
    number { 123 }
    neighborhood { 'centro' }
    city { 'Nova Andradina' }
    state { 'MS' }
    office_type { FactoryBot.create(:office_type) }
    profile_admin { FactoryBot.create(:profile_admin) }
  end
end
