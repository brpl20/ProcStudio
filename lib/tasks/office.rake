# frozen_string_literal: true
require 'bundler/setup'
require 'faker'

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task office: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    3.times do
      Office.create!(
        name: Faker::Company.name,
        cnpj: Faker::Company.brazilian_company_number,
        oab: Faker::Number.number(digits: 5),
        society: 'individual',
        foundation: Faker::Date.backward(days: 14),
        site: Faker::Internet.domain_name,
        cep: Faker::Number.number(digits: 5),
        street: Faker::Address.street_name,
        number: Faker::Address.building_number,
        neighborhood: Faker::Address.community,
        city: Faker::Address.city,
        state: Faker::Address.state_abbr,
        office_type: OfficeType.all.sample
        )
    end
  end
end
