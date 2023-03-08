# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    description { 'Casa' }
    zip_code { '79750000' }
    street { 'Rua Um' }
    number { '1252' }
    neighborhood { 'Centro' }
    city { 'Nova Andradina' }
    state { 'Mato Grosso do Sul' }
  end
end
