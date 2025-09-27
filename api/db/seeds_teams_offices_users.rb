# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

# ==========================================
# TEAMS
# ==========================================
Rails.logger.debug '[TEAMS] Creating Teams...'
team = Team.find_or_create_by!(name: 'Escritório Principal') do |t|
  t.subdomain = 'principal'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

team2 = Team.find_or_create_by!(name: 'Escritório Filial') do |t|
  t.subdomain = 'filial'
  Rails.logger.debug { "  [OK] Created team: #{t.name}" }
end

# ==========================================
# OFFICES with Polymorphic Associations
# ==========================================
Rails.logger.debug '[OFFICES] Creating Offices with nested attributes...'

office1 = Office.find_or_create_by!(cnpj: '49.609.519/0001-60') do |o|
  o.name = 'Escritório Advocacia Principal'
  o.oab_id = '15.074 PR'
  o.society = 'individual'
  o.foundation = Date.parse('2023-09-25')
  o.site = 'advocacia.com.br'
  o.team = team

  # Using nested attributes for polymorphic associations
  o.addresses_attributes = [
    {
      zip_code: '85810010',
      street: 'Rua Paraná',
      number: '3033',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '4532259000'
    }
  ]

  o.emails_attributes = [
    {
      email: 'u1@gmail.com',
      email_type: 'main'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Banco do Brasil',
      account_type: 'checking',
      agency: '1234',
      account: '567890',
      operation: '001',
      pix: '49.609.519/0001-60'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

Office.find_or_create_by!(cnpj: '11.222.333/0001-81') do |o|
  o.name = 'Escritório Advocacia Secundário'
  o.oab_id = '12.345 SP'
  o.society = 'company'
  o.foundation = Date.parse('2020-01-15')
  o.site = 'advocacia2.com.br'
  o.team = team2

  # Using nested attributes for polymorphic associations
  o.addresses_attributes = [
    {
      zip_code: '01310100',
      street: 'Avenida Paulista',
      number: '1500',
      complement: 'Sala 200',
      neighborhood: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '1132847000'
    },
    {
      phone_number: '11987654321'
    }
  ]

  o.emails_attributes = [
    {
      email: 'o1@gmail.com',
      email_type: 'main'
    },
    {
      email: 'o1.financeiro@gmail.com',
      email_type: 'secondary'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Santander',
      account_type: 'checking',
      agency: '0001',
      account: '123456',
      pix: 'contato@advocacia2.com.br'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# ==========================================
# USERS with Polymorphic Associations
# ==========================================
Rails.logger.debug '[USERS] Creating Users and UserProfiles with nested attributes...'

# User 1 - Main Lawyer
user1 = User.find_or_create_by!(email: 'u1@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user1) do |p|
  p.role = 'lawyer'
  p.name = 'João Augusto'
  p.last_name = 'Prado'
  p.gender = 'male'
  p.oab = '110.025 PR'
  p.rg = '998979601'
  p.cpf = '080.391.959-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1991-10-16')
  p.mother_name = 'Rosinha Mendes Prado'
  p.office = office1

  # Using nested attributes for polymorphic associations
  p.addresses_attributes = [
    {
      zip_code: '85810000',
      street: 'Rua XV de Novembro',
      number: '1234',
      complement: 'Apto 501',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'u2@gmail.com',
      email_type: 'work'
    },
    {
      email: 'u2.personal@gmail.com',
      email_type: 'personal'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Itaú',
      account_type: 'checking',
      agency: '5678',
      account: '12345',
      pix: '080.391.959-00'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 2 - Associate Lawyer
user2 = User.find_or_create_by!(email: 'u2@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user2) do |p|
  p.role = 'lawyer'
  p.name = 'Maria'
  p.last_name = 'Silva Santos'
  p.gender = 'female'
  p.oab = '98.765 SP'
  p.rg = '123456789'
  p.cpf = '123.456.789-00'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('1988-05-22')
  p.mother_name = 'Ana Silva'
  p.office = office1

  # Using nested attributes for polymorphic associations
  p.addresses_attributes = [
    {
      zip_code: '01310200',
      street: 'Rua Augusta',
      number: '2000',
      complement: 'Bloco B, Apto 102',
      neighborhood: 'Jardins',
      city: 'São Paulo',
      state: 'SP',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'maria.silva@advocacia.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Bradesco',
      account_type: 'checking',
      agency: '3333',
      account: '999999',
      pix: 'maria.silva@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 3 - Secretary
user3 = User.find_or_create_by!(email: 'ana.secretaria@advocacia.com.br') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user3) do |p|
  p.role = 'secretary'
  p.name = 'Ana'
  p.last_name = 'Costa'
  p.gender = 'female'
  p.rg = '987654321'
  p.cpf = '987.654.321-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1995-03-10')
  p.mother_name = 'Maria Costa'
  p.office = office1

  # Using nested attributes for polymorphic associations
  p.addresses_attributes = [
    {
      zip_code: '85810050',
      street: 'Rua Rio Grande do Sul',
      number: '789',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'ana.secretaria@advocacia.com.br',
      email_type: 'work'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

Rails.logger.debug '  [OK] Teams, Offices, and Users created successfully with polymorphic associations!'
