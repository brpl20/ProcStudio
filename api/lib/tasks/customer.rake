# frozen_string_literal: true

namespace :cad do
  desc 'Criação de Profile Customer'
  task customer: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    10.times do
      Customer.create(
        email: Faker::Internet.email,
        password: '123456',
        password_confirmation: '123456'
      )
    end

    10.times.each_with_index do |_, index|
      ProfileCustomer.create(
        customer_type: 'physical_person',
        name: Faker::Name.name,
        last_name: Faker::Name.last_name,
        gender: ['male', 'female'].sample,
        rg: Faker::Number.number(digits: 6),
        cpf: Faker::Number.number(digits: 11),
        cnpj: '',
        nationality: ['brazilian', 'foreigner'].sample,
        civil_status: 'single',
        capacity: ['able', 'unable'].sample,
        profession: Faker::Job.title,
        company: Faker::Company.name,
        birth: Faker::Date.birthday(min_age: 18, max_age: 65),
        mother_name: Faker::Name.name_with_middle,
        number_benefit: '',
        status: [0, 1].sample,
        document: nil,
        nit: Faker::Alphanumeric.alpha(number: 6),
        inss_password: Faker::Alphanumeric.alpha(number: 8),
        customer_id: index,
        phones_attributes: [
          { phone_number: Faker::PhoneNumber.phone_number },
          { phone_number: Faker::PhoneNumber.phone_number }
        ],
        emails_attributes: [
          { email: Faker::Internet.email },
          { email: Faker::Internet.email }
        ],
        addresses_attributes: [
          {
            description: 'Casa',
            zip_code: Faker::Address.zip_code,
            street: Faker::Address.street_name,
            number: Faker::Address.building_number,
            neighborhood: Faker::Address.community,
            city: Faker::Address.city,
            state: Faker::Address.state_abbr
          }
        ],
        bank_accounts_attributes: [
          {
            bank_name: Faker::Number.between(from: 1, to: 25),
            type_account: 'Conta Corrente',
            agency: Faker::Bank.routing_number,
            account: Faker::Bank.account_number,
            operation: '0',
            pix: Faker::Number.number(digits: 11)
          }
        ]
      )
    end
  end
end
