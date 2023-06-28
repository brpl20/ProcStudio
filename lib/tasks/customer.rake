# frozen_string_literal: true

namespace :cad do
  desc 'Criação de Profile Customer'
  task customer: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    20.times do
      Customer.create(
        email: Faker::Internet.email,
        password: '123456',
        password_confirmation: '123456'
      )
    end

    10.times.each_with_index do |_, index|
      ProfileCustomer.create(
        customer_type: [0,2,3].sample,
        name: Faker::Name.name,
        last_name: Faker::Name.last_name,
        gender: [0,1].sample,
        rg: Faker::Number.number(digits: 6),
        cpf: Faker::Number.number(digits: 11),
        cnpj: '',
        nationality: [0,1].sample,
        civil_status: (0..4).to_a.sample,
        capacity: (0..2).to_a.sample,
        profession: Faker::Job.title,
        company: Faker::Company.name,
        birth: Faker::Date.birthday(min_age: 18, max_age: 65),
        mother_name: Faker::Name.name_with_middle,
        number_benefit: '',
        status: [0,1].sample,
        document: nil,
        nit: Faker::Alphanumeric.alpha(number: 6),
        inss_password: Faker::Alphanumeric.alpha(number: 8),
        customer_id: index
      )
    end

    10.times.each_with_index do |_, index|
      ProfileCustomer.create(
        customer_type: 1,
        name: Faker::Name.name,
        last_name: Faker::Name.last_name,
        gender: [0,1].sample,
        rg: Faker::Number.number(digits: 6),
        cpf: '',
        cnpj: Faker::Company.brazilian_company_number,
        nationality: [0,1].sample,
        civil_status: [0,1].sample,
        capacity: (0..2).to_a.sample,
        profession: Faker::Job.title,
        company: Faker::Company.name,
        birth: Faker::Date.birthday(min_age: 18, max_age: 65),
        mother_name: Faker::Name.name_with_middle,
        number_benefit: '',
        status: [0,1].sample,
        document: nil,
        nit: Faker::Alphanumeric.alpha(number: 6),
        inss_password: Faker::Alphanumeric.alpha(number: 8),
        customer_id: (index + 10)
      )
    end
  end
end
