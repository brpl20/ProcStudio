# frozen_string_literal: true

Admin.create!(
  email: 'admin@procstudio.com.br',
  password: '123456',
  password_confirmation: '123456'
)

ProfileAdmin.create!(
  role: 1,
  name: 'Administrador padrão',
  lastname: 'Sobrenome',
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
