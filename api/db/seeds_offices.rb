# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

# ==========================================
# OFFICES with Polymorphic Associations and UserOffices
# ==========================================
Rails.logger.debug '[OFFICES] Creating Offices with nested attributes and user relationships...'

# Get teams and users
team1 = Team.find_by!(subdomain: 'joao-prado')
team2 = Team.find_by!(subdomain: 'terezinha-lawyer')
team3 = Team.find_by!(subdomain: 'machado-associados')
team4 = Team.find_by!(subdomain: 'silva-partners')
team5 = Team.find_by!(subdomain: 'costa-advogados')

user1 = User.find_by!(email: 'u1@gmail.com')
user2 = User.find_by!(email: 'u2@gmail.com')
user3 = User.find_by!(email: 'u3@gmail.com')
user4 = User.find_by!(email: 'u4@gmail.com')
user5 = User.find_by!(email: 'u5@gmail.com')
user6 = User.find_by!(email: 'u6@gmail.com')
user7 = User.find_by!(email: 'u7@gmail.com')
user8 = User.find_by!(email: 'u8@gmail.com')
user9 = User.find_by!(email: 'u9@gmail.com')
user10 = User.find_by!(email: 'u10@gmail.com')

# ==========================================
# TEAM 1 - Individual Office (1 lawyer)
# ==========================================
office1 = Office.find_or_create_by!(cnpj: '61.457.002/6403-43') do |o|
  o.name = 'Escritório Advocacia João Augusto Prado'
  o.oab_id = 'PR_15047'
  o.society = 'individual'
  o.foundation = Date.parse('25-09-2023')
  o.site = 'advocacia.com.br'
  o.team = team1
  o.quote_value = 150.00
  o.number_of_quotes = 10
  o.accounting_type = 'simple'

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
      email: 'contato@joaoprado.adv.br',
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
      pix: '61.457.002/6403-43'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# Create UserOffice for Team 1 - Individual office
UserOffice.find_or_create_by!(user: user1, office: office1) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 100.0
  uo.is_administrator = true
  uo.entry_date = office1.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user1.email} -> #{office1.name} (100%)" }
end

# Update user profile with office
user1.user_profile.update!(office: office1)

# ==========================================
# TEAM 2 - Shared Office (2 lawyers)
# ==========================================
office2 = Office.find_or_create_by!(cnpj: '08.177.535/5326-69') do |o|
  o.name = 'Escritório Advocacia Terezinha e Mendes'
  o.oab_id = 'PR_1821'
  o.society = 'company'
  o.foundation = Date.parse('15-01-2020')
  o.site = 'terezinha-mendes.adv.br'
  o.team = team2
  o.quote_value = 200.00
  o.number_of_quotes = 15
  o.accounting_type = 'presumed_profit'

  # Using nested attributes for polymorphic associations
  o.addresses_attributes = [
    {
      zip_code: '85810100',
      street: 'Avenida Brasil',
      number: '1500',
      complement: 'Sala 200',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '4532847000'
    },
    {
      phone_number: '45987654321'
    }
  ]

  o.emails_attributes = [
    {
      email: 'contato@terezinha-mendes.adv.br',
      email_type: 'main'
    },
    {
      email: 'financeiro@terezinha-mendes.adv.br',
      email_type: 'secondary'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Santander',
      account_type: 'checking',
      agency: '0001',
      account: '123456',
      pix: 'contato@terezinha-mendes.adv.br'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# Create UserOffices for Team 2 - Shared office
UserOffice.find_or_create_by!(user: user2, office: office2) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 60.0
  uo.is_administrator = true
  uo.entry_date = office2.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user2.email} -> #{office2.name} (60%)" }
end

UserOffice.find_or_create_by!(user: user3, office: office2) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 40.0
  uo.is_administrator = false
  uo.entry_date = office2.foundation + 6.months
  Rails.logger.debug { "  [OK] Created UserOffice: #{user3.email} -> #{office2.name} (40%)" }
end

# Update user profiles with office
user2.user_profile.update!(office: office2)
user3.user_profile.update!(office: office2)

# ==========================================
# TEAM 3 - Two Offices (3 lawyers total)
# Office 3A: Individual office for 1 lawyer
# Office 3B: Shared office for 2 lawyers
# ==========================================

# Office 3A - Individual office for Antonio Machado
office3a = Office.find_or_create_by!(cnpj: '00.714.999/6011-34') do |o|
  o.name = 'Machado Advocacia Individual'
  o.oab_id = 'PR_2001'
  o.society = 'individual'
  o.foundation = Date.parse('01-03-2019')
  o.site = 'machado-individual.adv.br'
  o.team = team3
  o.quote_value = 250.00
  o.number_of_quotes = 20
  o.accounting_type = 'real_profit'

  o.addresses_attributes = [
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

  o.phones_attributes = [
    {
      phone_number: '4133221100'
    }
  ]

  o.emails_attributes = [
    {
      email: 'antonio@machado-individual.adv.br',
      email_type: 'main'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Caixa Econômica Federal',
      account_type: 'checking',
      agency: '0001',
      account: '11111',
      pix: '00.714.999/6011-34'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# UserOffice for Office 3A
UserOffice.find_or_create_by!(user: user4, office: office3a) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 100.0
  uo.is_administrator = true
  uo.entry_date = office3a.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user4.email} -> #{office3a.name} (100%)" }
end

user4.user_profile.update!(office: office3a)

# Office 3B - Shared office for Patricia and Roberto
office3b = Office.find_or_create_by!(cnpj: '37.794.415/8709-20') do |o|
  o.name = 'Oliveira & Costa Advogados Associados'
  o.oab_id = 'PR_2002'
  o.society = 'company'
  o.foundation = Date.parse('15-06-2021')
  o.site = 'oliveira-costa.adv.br'
  o.team = team3
  o.quote_value = 180.00
  o.number_of_quotes = 12
  o.accounting_type = 'simple'

  o.addresses_attributes = [
    {
      zip_code: '80040000',
      street: 'Rua XV de Novembro',
      number: '2300',
      complement: 'Andar 3',
      neighborhood: 'Centro',
      city: 'Curitiba',
      state: 'PR',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '4133335555'
    }
  ]

  o.emails_attributes = [
    {
      email: 'contato@oliveira-costa.adv.br',
      email_type: 'main'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Itaú',
      account_type: 'checking',
      agency: '2222',
      account: '33333',
      pix: 'contato@oliveira-costa.adv.br'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# UserOffices for Office 3B
UserOffice.find_or_create_by!(user: user5, office: office3b) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 50.0
  uo.is_administrator = true
  uo.entry_date = office3b.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user5.email} -> #{office3b.name} (50%)" }
end

UserOffice.find_or_create_by!(user: user6, office: office3b) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 50.0
  uo.is_administrator = false
  uo.entry_date = office3b.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user6.email} -> #{office3b.name} (50%)" }
end

user5.user_profile.update!(office: office3b)
user6.user_profile.update!(office: office3b)

# ==========================================
# TEAM 4 - Shared Office (2 lawyers)
# ==========================================
office4 = Office.find_or_create_by!(cnpj: '03.382.290/3891-00') do |o|
  o.name = 'Silva & Pereira Sociedade de Advogados'
  o.oab_id = 'PR_3001'
  o.society = 'company'
  o.foundation = Date.parse('10-08-2018')
  o.site = 'silva-pereira.adv.br'
  o.team = team4
  o.quote_value = 220.00
  o.number_of_quotes = 18
  o.accounting_type = 'presumed_profit'

  o.addresses_attributes = [
    {
      zip_code: '87030000',
      street: 'Avenida Colombo',
      number: '5790',
      complement: 'Bloco C, Sala 12',
      neighborhood: 'Zona 7',
      city: 'Maringá',
      state: 'PR',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '4432627000'
    },
    {
      phone_number: '44998765432'
    }
  ]

  o.emails_attributes = [
    {
      email: 'contato@silva-pereira.adv.br',
      email_type: 'main'
    },
    {
      email: 'juridico@silva-pereira.adv.br',
      email_type: 'secondary'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Bradesco',
      account_type: 'checking',
      agency: '4444',
      account: '55555',
      pix: '03.382.290/3891-00'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# Create UserOffices for Team 4
UserOffice.find_or_create_by!(user: user7, office: office4) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 70.0
  uo.is_administrator = true
  uo.entry_date = office4.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user7.email} -> #{office4.name} (70%)" }
end

UserOffice.find_or_create_by!(user: user8, office: office4) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 30.0
  uo.is_administrator = false
  uo.entry_date = Date.parse('01-01-2019')
  Rails.logger.debug { "  [OK] Created UserOffice: #{user8.email} -> #{office4.name} (30%)" }
end

user7.user_profile.update!(office: office4)
user8.user_profile.update!(office: office4)

# ==========================================
# TEAM 5 - Shared Office (2 lawyers)
# ==========================================
office5 = Office.find_or_create_by!(cnpj: '32.423.347/9878-17') do |o|
  o.name = 'Costa & Rodrigues Advogados'
  o.oab_id = 'PR_4001'
  o.society = 'company'
  o.foundation = Date.parse('20-05-2022')
  o.site = 'costa-rodrigues.adv.br'
  o.team = team5
  o.quote_value = 175.00
  o.number_of_quotes = 25
  o.accounting_type = 'real_profit'

  o.addresses_attributes = [
    {
      zip_code: '84010000',
      street: 'Rua Santana',
      number: '777',
      complement: 'Ed. Empresarial, Sala 501',
      neighborhood: 'Centro',
      city: 'Ponta Grossa',
      state: 'PR',
      address_type: 'main'
    }
  ]

  o.phones_attributes = [
    {
      phone_number: '4232228888'
    },
    {
      phone_number: '42999887766'
    }
  ]

  o.emails_attributes = [
    {
      email: 'contato@costa-rodrigues.adv.br',
      email_type: 'main'
    },
    {
      email: 'administrativo@costa-rodrigues.adv.br',
      email_type: 'secondary'
    }
  ]

  o.bank_accounts_attributes = [
    {
      bank_name: 'Banco do Brasil',
      account_type: 'checking',
      agency: '5555',
      account: '666777',
      operation: '001',
      pix: 'contato@costa-rodrigues.adv.br'
    }
  ]

  Rails.logger.debug { "  [OK] Created office: #{o.name} with nested attributes" }
end

# Create UserOffices for Team 5
UserOffice.find_or_create_by!(user: user9, office: office5) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 55.0
  uo.is_administrator = true
  uo.entry_date = office5.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user9.email} -> #{office5.name} (55%)" }
end

UserOffice.find_or_create_by!(user: user10, office: office5) do |uo|
  uo.partnership_type = 'socio'
  uo.partnership_percentage = 45.0
  uo.is_administrator = false
  uo.entry_date = office5.foundation
  Rails.logger.debug { "  [OK] Created UserOffice: #{user10.email} -> #{office5.name} (45%)" }
end

user9.user_profile.update!(office: office5)
user10.user_profile.update!(office: office5)

Rails.logger.debug '  [OK] All Offices created successfully with UserOffice relationships!'