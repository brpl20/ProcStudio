# frozen_string_literal: true

Faker::Config.locale = 'pt-BR'

Admin.create!(
  email: 'admin@procstudio.com.br',
  password: '123456',
  password_confirmation: '123456'
)

ProfileAdmin.create!(
  role: 1,
  name: 'Administrador padrão',
  last_name: 'Sobrenome',
  gender: 1,
  oab: '12345',
  rg: '12.345.563-85',
  cpf: '123.456.879-00',
  nationality: 'Brasileira',
  civil_status: 1,
  birth: '12-01-2000',
  mother_name: 'Joana Martinez Rodriguez',
  status: 1,
  admin: Admin.last
)

puts 'Criando Customers'
5.times do |_index|
  Customer.create!(
    email: Faker::Internet.email,
    password: '123456',
    password_confirmation: '123456'
  )
end

puts 'Criando ProfileCustomers'
ProfileCustomer.create!(
  customer_type: 'Representative', name: Faker::Name.name, customer_id: Customer.pluck(:id).sample,
  last_name: Faker::Name.last_name, cpf: Faker::Number.number(digits: 11), rg: Faker::Number.number(digits: 6),
  birth: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: :other,
  civil_status: :married, nationality: :foreigner,
  profession: Faker::Company.profession,
  company: Faker::Company.name,
  nit: Faker::Number.number(digits: 5), mother_name: Faker::Name.name
)
ProfileCustomer.create!(
  customer_type: 'Accounting', name: Faker::Name.name, customer_id: Customer.pluck(:id).sample,
  last_name: Faker::Name.last_name, cpf: Faker::Number.number(digits: 11), rg: Faker::Number.number(digits: 6),
  birth: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: :female,
  civil_status: :married, nationality: :brazilian,
  profession: Faker::Company.profession,
  company: Faker::Company.name,
  nit: Faker::Number.number(digits: 5), mother_name: Faker::Name.name
)
ProfileCustomer.create!(
  customer_type: 'Company', name: Faker::Name.name, customer_id: Customer.pluck(:id).sample,
  company: Faker::Company.name, cnpj: Faker::Number.number(digits: 14),
  status: 'Ativo'
)
ProfileCustomer.create!(
  customer_type: 'Person', name: Faker::Name.name, customer_id: Customer.pluck(:id).sample,
  last_name: Faker::Name.last_name, cpf: Faker::Number.number(digits: 11), rg: Faker::Number.number(digits: 6),
  birth: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: :male,
  civil_status: :single, nationality: :brazilian,
  profession: Faker::Company.profession,
  company: Faker::Company.name,
  nit: Faker::Number.number(digits: 5), mother_name: Faker::Name.name
)
