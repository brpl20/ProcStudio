# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

# ==========================================
# USERS with Polymorphic Associations
# ==========================================
Rails.logger.debug '[USERS] Creating Users and UserProfiles with nested attributes...'

# Get teams
team1 = Team.find_by!(subdomain: 'joao-prado')
team2 = Team.find_by!(subdomain: 'terezinha-lawyer')
team3 = Team.find_by!(subdomain: 'machado-associados')
team4 = Team.find_by!(subdomain: 'silva-partners')
team5 = Team.find_by!(subdomain: 'costa-advogados')

# ==========================================
# TEAM 1 - 1 lawyer (individual office)
# ==========================================

# User 1 - Main Lawyer for Team 1
user1 = User.find_or_create_by!(email: 'u1@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team1
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user1) do |p|
  p.role = 'lawyer'
  p.name = 'João Augusto'
  p.last_name = 'Prado'
  p.gender = 'male'
  p.oab = 'PR_110025'
  p.rg = '998979601'
  p.cpf = '080.391.959-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('16-10-1991')
  p.mother_name = 'Rosinha Mendes Prado'

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
      email: 'joao.prado.work@gmail.com',
      email_type: 'work'
    },
    {
      email: 'joao.personal@gmail.com',
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

# ==========================================
# TEAM 2 - 2 lawyers (shared office)
# ==========================================

# User 2 - First Lawyer for Team 2
user2 = User.find_or_create_by!(email: 'u2@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team2
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user2) do |p|
  p.role = 'lawyer'
  p.name = 'Terezinha'
  p.last_name = 'Silva Santos'
  p.gender = 'female'
  p.oab = 'PR_110026'
  p.rg = '123456789'
  p.cpf = '123.456.789-00'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('22-05-1988')
  p.mother_name = 'Ana Silva'

  # Using nested attributes for polymorphic associations
  p.addresses_attributes = [
    {
      zip_code: '85810100',
      street: 'Rua Paraná',
      number: '2000',
      complement: 'Bloco B, Apto 102',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'terezinha.silva@advocacia.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Bradesco',
      account_type: 'checking',
      agency: '3333',
      account: '999999',
      pix: 'terezinha.silva@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 3 - Second Lawyer for Team 2
user3 = User.find_or_create_by!(email: 'u3@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team2
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user3) do |p|
  p.role = 'lawyer'
  p.name = 'Carlos'
  p.last_name = 'Mendes'
  p.gender = 'male'
  p.oab = 'PR_110027'
  p.rg = '987654321'
  p.cpf = '987.654.321-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('10-03-1985')
  p.mother_name = 'Maria Mendes'

  p.addresses_attributes = [
    {
      zip_code: '85810200',
      street: 'Avenida Brasil',
      number: '789',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'carlos.mendes@advocacia.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Banco do Brasil',
      account_type: 'checking',
      agency: '1234',
      account: '567890',
      pix: 'carlos.mendes@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# ==========================================
# TEAM 3 - 3 lawyers (will have 2 offices)
# ==========================================

# User 4 - First Lawyer for Team 3
user4 = User.find_or_create_by!(email: 'u4@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team3
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user4) do |p|
  p.role = 'lawyer'
  p.name = 'Antonio'
  p.last_name = 'Machado'
  p.gender = 'male'
  p.oab = 'PR_110028'
  p.rg = '111222333'
  p.cpf = '111.222.333-44'
  p.nationality = 'brazilian'
  p.civil_status = 'divorced'
  p.birth = Date.parse('15-08-1980')
  p.mother_name = 'Helena Machado'

  p.addresses_attributes = [
    {
      zip_code: '80030000',
      street: 'Rua Marechal Deodoro',
      number: '1500',
      complement: 'Sala 10',
      neighborhood: 'Centro',
      city: 'Curitiba',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'antonio.machado@machado-associados.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Caixa Econômica Federal',
      account_type: 'checking',
      agency: '0001',
      account: '11111',
      pix: '111.222.333-44'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 5 - Second Lawyer for Team 3
user5 = User.find_or_create_by!(email: 'u5@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team3
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user5) do |p|
  p.role = 'lawyer'
  p.name = 'Patricia'
  p.last_name = 'Oliveira'
  p.gender = 'female'
  p.oab = 'PR_110029'
  p.rg = '444555666'
  p.cpf = '444.555.666-77'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('28-02-1990')
  p.mother_name = 'Rosa Oliveira'

  p.addresses_attributes = [
    {
      zip_code: '80040000',
      street: 'Rua XV de Novembro',
      number: '2300',
      complement: 'Apto 15',
      neighborhood: 'Centro',
      city: 'Curitiba',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'patricia.oliveira@machado-associados.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Santander',
      account_type: 'checking',
      agency: '2222',
      account: '33333',
      pix: 'patricia.oliveira@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 6 - Third Lawyer for Team 3
user6 = User.find_or_create_by!(email: 'u6@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team3
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user6) do |p|
  p.role = 'lawyer'
  p.name = 'Roberto'
  p.last_name = 'Costa'
  p.gender = 'male'
  p.oab = 'PR_110030'
  p.rg = '777888999'
  p.cpf = '777.888.999-00'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('12-11-1992')
  p.mother_name = 'Julia Costa'

  p.addresses_attributes = [
    {
      zip_code: '80050000',
      street: 'Rua Comendador Araújo',
      number: '500',
      neighborhood: 'Centro',
      city: 'Curitiba',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'roberto.costa@machado-associados.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Nubank',
      account_type: 'checking',
      agency: '0001',
      account: '777888',
      pix: 'roberto.costa@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# ==========================================
# TEAM 4 - 2 lawyers (shared office)
# ==========================================

# User 7 - First Lawyer for Team 4
user7 = User.find_or_create_by!(email: 'u7@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team4
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user7) do |p|
  p.role = 'lawyer'
  p.name = 'Fernando'
  p.last_name = 'Silva'
  p.gender = 'male'
  p.oab = 'PR_110031'
  p.rg = '222333444'
  p.cpf = '222.333.444-55'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('05-07-1987')
  p.mother_name = 'Ana Paula Silva'

  p.addresses_attributes = [
    {
      zip_code: '87030000',
      street: 'Avenida Colombo',
      number: '5790',
      neighborhood: 'Zona 7',
      city: 'Maringá',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'fernando.silva@silva-partners.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Sicoob',
      account_type: 'checking',
      agency: '4444',
      account: '55555',
      pix: '222.333.444-55'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 8 - Second Lawyer for Team 4
user8 = User.find_or_create_by!(email: 'u8@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team4
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user8) do |p|
  p.role = 'lawyer'
  p.name = 'Juliana'
  p.last_name = 'Pereira'
  p.gender = 'female'
  p.oab = 'PR_110032'
  p.rg = '555666777'
  p.cpf = '555.666.777-88'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('18-09-1993')
  p.mother_name = 'Lucia Pereira'

  p.addresses_attributes = [
    {
      zip_code: '87040000',
      street: 'Rua Santos Dumont',
      number: '123',
      complement: 'Sala 5',
      neighborhood: 'Zona 1',
      city: 'Maringá',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'juliana.pereira@silva-partners.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'Inter',
      account_type: 'checking',
      agency: '0001',
      account: '666777',
      pix: 'juliana.pereira@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# ==========================================
# TEAM 5 - 2 lawyers (shared office)
# ==========================================

# User 9 - First Lawyer for Team 5
user9 = User.find_or_create_by!(email: 'u9@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team5
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user9) do |p|
  p.role = 'lawyer'
  p.name = 'Ricardo'
  p.last_name = 'Costa'
  p.gender = 'male'
  p.oab = 'PR_110033'
  p.rg = '888999000'
  p.cpf = '888.999.000-11'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('25-12-1982')
  p.mother_name = 'Teresa Costa'

  p.addresses_attributes = [
    {
      zip_code: '84010000',
      street: 'Rua Santana',
      number: '777',
      neighborhood: 'Centro',
      city: 'Ponta Grossa',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'ricardo.costa@costa-advogados.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'C6 Bank',
      account_type: 'checking',
      agency: '0001',
      account: '888999',
      pix: 'ricardo.costa@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

# User 10 - Second Lawyer for Team 5
user10 = User.find_or_create_by!(email: 'u10@gmail.com') do |u|
  u.password = '123456'
  u.password_confirmation = '123456'
  u.team = team5
  u.status = 'active'
  Rails.logger.debug { "  [OK] Created user: #{u.email}" }
end

UserProfile.find_or_create_by!(user: user10) do |p|
  p.role = 'lawyer'
  p.name = 'Amanda'
  p.last_name = 'Rodrigues'
  p.gender = 'female'
  p.oab = 'PR_110034'
  p.rg = '111000222'
  p.cpf = '111.000.222-33'
  p.nationality = 'brazilian'
  p.civil_status = 'divorced'
  p.birth = Date.parse('30-06-1986')
  p.mother_name = 'Sandra Rodrigues'

  p.addresses_attributes = [
    {
      zip_code: '84020000',
      street: 'Avenida Vicente Machado',
      number: '1200',
      complement: 'Cobertura',
      neighborhood: 'Centro',
      city: 'Ponta Grossa',
      state: 'PR',
      address_type: 'main'
    }
  ]

  p.emails_attributes = [
    {
      email: 'amanda.rodrigues@costa-advogados.com.br',
      email_type: 'work'
    }
  ]

  p.bank_accounts_attributes = [
    {
      bank_name: 'PagBank',
      account_type: 'checking',
      agency: '0001',
      account: '111222',
      pix: 'amanda.rodrigues@pix.com'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile: #{p.full_name} with nested attributes" }
end

Rails.logger.debug '  [OK] All Users created successfully with polymorphic associations!'