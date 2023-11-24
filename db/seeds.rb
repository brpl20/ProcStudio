# frozen_string_literal: true

Faker::Config.locale = 'pt-BR'

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
  office_type: OfficeType.find(1)
)

Admin.create!(
  email: 'adminfront@procstudio.com.br',
  password: '123456',
  password_confirmation: '123456'
)

ProfileAdmin.create!(
  role: 'lawyer',
  name: 'Bruno',
  last_name: 'Pellizzetti (FrontAdmin)',
  gender: 'male',
  oab: '54.159 PR',
  rg: '12.345.563-85',
  cpf: '123.456.879-00',
  nationality: 'brazilian',
  civil_status: 'single',
  birth: '12-01-1986',
  mother_name: 'Marta da Silva',
  status: 'active',
  admin: Admin.last,
  office: Office.last
)

Admin.create!(
  email: 'adminapi@procstudio.com.br',
  password: '123456',
  password_confirmation: '123456'
)

ProfileAdmin.create!(
  role: 'lawyer',
  name: 'Eduarda',
  last_name: 'Blackter (ApiAdmin)',
  gender: 'female',
  oab: '90.185 PR',
  rg: '12.345.563-85',
  cpf: '123.456.879-00',
  nationality: 'brazilian',
  civil_status: 'married',
  birth: '12-01-1992',
  mother_name: 'Joaninha Blackter',
  status: 'active',
  admin: Admin.last,
  office: Office.last
)

# OFFICE nil not working --- belongs to
