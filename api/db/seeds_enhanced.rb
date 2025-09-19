# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

puts '🌱 Starting enhanced seed process with multi-tenancy demonstration...'
puts '=' * 50

# ==========================================
# TEAMS - Multi-tenancy Foundation
# ==========================================
puts '📁 Creating Teams with Settings...'
team_principal = Team.find_or_create_by!(name: 'Escritório Principal') do |t|
  t.subdomain = 'principal'
  t.settings = {
    'theme' => 'professional',
    'language' => 'pt-BR',
    'timezone' => 'America/Sao_Paulo',
    'business_hours' => '08:00-18:00',
    'notification_preferences' => {
      'email' => true,
      'sms' => false,
      'deadline_alerts' => 3
    }
  }
  puts "  ✅ Created team: #{t.name} (subdomain: #{t.subdomain})"
end

team_filial = Team.find_or_create_by!(name: 'Escritório Filial SP') do |t|
  t.subdomain = 'filial-sp'
  t.settings = {
    'theme' => 'modern',
    'language' => 'pt-BR',
    'timezone' => 'America/Sao_Paulo',
    'business_hours' => '09:00-19:00',
    'notification_preferences' => {
      'email' => true,
      'sms' => true,
      'deadline_alerts' => 5
    }
  }
  puts "  ✅ Created team: #{t.name} (subdomain: #{t.subdomain})"
end

team_parceiro = Team.find_or_create_by!(name: 'Escritório Parceiro RJ') do |t|
  t.subdomain = 'parceiro-rj'
  t.settings = {
    'theme' => 'corporate',
    'language' => 'pt-BR',
    'timezone' => 'America/Sao_Paulo',
    'business_hours' => '08:30-17:30',
    'notification_preferences' => {
      'email' => true,
      'sms' => false,
      'deadline_alerts' => 7
    }
  }
  puts "  ✅ Created team: #{t.name} (subdomain: #{t.subdomain})"
end

# ==========================================
# LAW AREAS (Áreas do Direito)
# ==========================================
puts '⚖️  Creating Law Areas...'
law_areas_data = [
  { code: 'ADM', name: 'Administrativo', parent: nil },
  { code: 'CIV', name: 'Cível', parent: nil },
  { code: 'CRIM', name: 'Criminal', parent: nil },
  { code: 'PREV', name: 'Previdenciário', parent: nil },
  { code: 'TRAB', name: 'Trabalhista', parent: nil },
  { code: 'TRIB', name: 'Tributário', parent: nil },
  { code: 'EMP', name: 'Empresarial', parent: nil },
  { code: 'IMOB', name: 'Imobiliário', parent: nil },
  { code: 'OUTROS', name: 'Outros', parent: nil },

  # Sub-areas for Cível
  { code: 'FAM', name: 'Família', parent: 'CIV' },
  { code: 'CONS', name: 'Consumidor', parent: 'CIV' },
  { code: 'DANO', name: 'Danos Morais', parent: 'CIV' },
  { code: 'SUC', name: 'Sucessões', parent: 'CIV' },

  # Sub-areas for Tributário
  { code: 'ASF', name: 'Asfalto', parent: 'TRIB' },
  { code: 'ALV', name: 'Alvará', parent: 'TRIB' },
  { code: 'PIS', name: 'PIS/COFINS', parent: 'TRIB' },
  { code: 'IPTU', name: 'IPTU', parent: 'TRIB' },

  # Sub-areas for Previdenciário
  { code: 'APOT', name: 'Aposentadoria por Tempo', parent: 'PREV' },
  { code: 'APOI', name: 'Aposentadoria por Idade', parent: 'PREV' },
  { code: 'APOR', name: 'Aposentadoria Rural', parent: 'PREV' },
  { code: 'INV', name: 'Invalidez', parent: 'PREV' },
  { code: 'REV', name: 'Revisão de Benefício', parent: 'PREV' },
  { code: 'BPC', name: 'BPC/LOAS', parent: 'PREV' },

  # Sub-areas for Trabalhista
  { code: 'RECL', name: 'Reclamatória Trabalhista', parent: 'TRAB' },
  { code: 'REV_TRAB', name: 'Revisão Trabalhista', parent: 'TRAB' },

  # Sub-areas for Empresarial
  { code: 'CONT_SOC', name: 'Contratos Sociais', parent: 'EMP' },
  { code: 'FAL', name: 'Falência', parent: 'EMP' },
  { code: 'REC_JUD', name: 'Recuperação Judicial', parent: 'EMP' }
]

law_areas_data.each do |data|
  parent = data[:parent] ? LawArea.find_by(code: data[:parent], parent_area_id: nil) : nil
  
  LawArea.find_or_create_by!(
    code: data[:code],
    parent_area_id: parent&.id,
    created_by_team_id: nil # System areas
  ) do |la|
    la.name = data[:name]
    la.active = true
    la.sort_order = law_areas_data.index(data)
    puts "  ✅ Created law area: #{la.full_name}"
  end
end

# Team-specific custom law areas
LawArea.find_or_create_by!(
  code: 'CUSTOM_PR',
  name: 'Direito Digital',
  parent_area_id: nil,
  created_by_team_id: team_principal.id
) do |la|
  la.active = true
  la.sort_order = 100
  puts "  ✅ Created team-specific law area: #{la.name} for #{team_principal.name}"
end

# ==========================================
# OFFICES with Complete Details
# ==========================================
puts '🏢 Creating Offices with Financial Details...'

# Principal Office - Large firm
office_principal = Office.find_or_create_by!(cnpj: '49.609.519/0001-60') do |o|
  o.name = 'Prado & Associados Advocacia'
  o.oab_id = '15.074 PR'
  o.oab_inscricao = 'OAB/PR 15.074'
  o.oab_link = 'https://www.oabpr.org.br/sociedade/15074'
  o.oab_status = 'active'
  o.society = 'company' # Large law firm
  o.accounting_type = 'real_profit' # Larger firms use real profit
  o.foundation = Date.parse('2015-09-25')
  o.site = 'www.pradoadvocacia.com.br'
  o.quote_value = 15000.00 # Monthly quota for partners
  o.number_of_quotes = 12
  o.team = team_principal
  puts "  ✅ Created office: #{o.name}"
end

# Add multiple addresses for principal office
office_principal.addresses.find_or_create_by!(
  zip_code: '85810010',
  street: 'Rua Paraná',
  number: '3033',
  address_type: 'main'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  a.complement = 'Edifício Empresarial, Salas 1001-1005'
  puts "  ✅ Created main address for office: #{office_principal.name}"
end

office_principal.addresses.find_or_create_by!(
  zip_code: '85810015',
  street: 'Av. Brasil',
  number: '5000',
  address_type: 'billing'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  a.complement = 'Sala 201'
  puts "  ✅ Created billing address for office: #{office_principal.name}"
end

# Add phones for principal office
office_principal.phones.find_or_create_by!(phone_number: '4532259000') do |p|
  puts "  ✅ Created main phone for office: #{office_principal.name}"
end

office_principal.phones.find_or_create_by!(phone_number: '45999887766') do |p|
  puts "  ✅ Created mobile phone for office: #{office_principal.name}"
end

# Filial Office - Medium firm
office_filial = Office.find_or_create_by!(cnpj: '11.222.333/0001-81') do |o|
  o.name = 'Silva & Santos Sociedade de Advogados'
  o.oab_id = '12.345 SP'
  o.oab_inscricao = 'OAB/SP 12.345'
  o.oab_link = 'https://www.oabsp.org.br/sociedade/12345'
  o.oab_status = 'active'
  o.society = 'simple' # Simple society
  o.accounting_type = 'presumed_profit' # Medium firms often use presumed
  o.foundation = Date.parse('2020-01-15')
  o.site = 'www.silvasantos.adv.br'
  o.quote_value = 8000.00
  o.number_of_quotes = 12
  o.team = team_filial
  puts "  ✅ Created office: #{o.name}"
end

office_filial.addresses.find_or_create_by!(
  zip_code: '01310100',
  street: 'Avenida Paulista',
  number: '1500',
  address_type: 'main'
) do |a|
  a.neighborhood = 'Bela Vista'
  a.city = 'São Paulo'
  a.state = 'SP'
  a.complement = 'Conjunto 402'
  puts "  ✅ Created address for office: #{office_filial.name}"
end

office_filial.phones.find_or_create_by!(phone_number: '1132847000') do |_p|
  puts "  ✅ Created phone for office: #{office_filial.name}"
end

# Partner Office - Solo practitioner
office_parceiro = Office.find_or_create_by!(cnpj: '44.555.666/0001-77') do |o|
  o.name = 'Costa Advogado Autônomo'
  o.oab_id = '98.765 RJ'
  o.oab_inscricao = 'OAB/RJ 98.765'
  o.oab_status = 'active'
  o.society = 'individual' # Solo practitioner
  o.accounting_type = 'simple' # Individual uses simple
  o.foundation = Date.parse('2022-06-01')
  o.site = 'www.costaadv.com.br'
  o.quote_value = 5000.00
  o.number_of_quotes = 12
  o.team = team_parceiro
  puts "  ✅ Created office: #{o.name}"
end

office_parceiro.addresses.find_or_create_by!(
  zip_code: '20031000',
  street: 'Rua da Assembleia',
  number: '10',
  address_type: 'main'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Rio de Janeiro'
  a.state = 'RJ'
  a.complement = 'Sala 1205'
  puts "  ✅ Created address for office: #{office_parceiro.name}"
end

office_parceiro.phones.find_or_create_by!(phone_number: '2133334444') do |_p|
  puts "  ✅ Created phone for office: #{office_parceiro.name}"
end

# ==========================================
# USERS with Diverse Roles
# ==========================================
puts '👤 Creating Users with Diverse Roles and UserProfiles...'

# Team Principal Users
# Senior Partner
user_senior_partner = User.find_or_create_by!(email: 'joao.prado@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_senior_partner = UserProfile.find_or_create_by!(user: user_senior_partner) do |p|
  p.role = 'lawyer'
  p.status = 'active'
  p.name = 'João Augusto'
  p.last_name = 'Prado'
  p.gender = 'male'
  p.oab = '110.025 PR'
  p.rg = '998979601'
  p.cpf = '080.391.959-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1975-10-16')
  p.mother_name = 'Rosinha Mendes Prado'
  p.origin = 'Cascavel, PR'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Senior Partner)"
end

# Create UserOffice with partnership details
UserOffice.find_or_create_by!(
  user_profile: profile_senior_partner,
  office: office_principal
) do |uo|
  uo.partnership_type = 'partner'
  uo.partnership_percentage = 40.0
  uo.joining_date = Date.parse('2015-09-25')
  puts "  ✅ Created partnership: #{profile_senior_partner.full_name} - 40% partner"
end

# Junior Partner
user_junior_partner = User.find_or_create_by!(email: 'maria.silva@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_junior_partner = UserProfile.find_or_create_by!(user: user_junior_partner) do |p|
  p.role = 'lawyer'
  p.status = 'active'
  p.name = 'Maria'
  p.last_name = 'Silva Santos'
  p.gender = 'female'
  p.oab = '98.765 SP'
  p.rg = '123456789'
  p.cpf = '123.456.789-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1988-05-22')
  p.mother_name = 'Ana Silva'
  p.origin = 'São Paulo, SP'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Junior Partner)"
end

UserOffice.find_or_create_by!(
  user_profile: profile_junior_partner,
  office: office_principal
) do |uo|
  uo.partnership_type = 'partner'
  uo.partnership_percentage = 20.0
  uo.joining_date = Date.parse('2020-01-01')
  puts "  ✅ Created partnership: #{profile_junior_partner.full_name} - 20% partner"
end

# Associate Lawyer
user_associate = User.find_or_create_by!(email: 'carlos.mendes@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_associate = UserProfile.find_or_create_by!(user: user_associate) do |p|
  p.role = 'lawyer'
  p.status = 'active'
  p.name = 'Carlos'
  p.last_name = 'Mendes'
  p.gender = 'male'
  p.oab = '150.123 PR'
  p.rg = '555666777'
  p.cpf = '555.666.777-88'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('1992-03-15')
  p.mother_name = 'Lucia Mendes'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Associate)"
end

UserOffice.find_or_create_by!(
  user_profile: profile_associate,
  office: office_principal
) do |uo|
  uo.partnership_type = 'associate'
  uo.partnership_percentage = 0.0
  uo.joining_date = Date.parse('2022-03-01')
  puts "  ✅ Created association: #{profile_associate.full_name} - Associate"
end

# Trainee Lawyer
user_trainee = User.find_or_create_by!(email: 'julia.costa@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_trainee = UserProfile.find_or_create_by!(user: user_trainee) do |p|
  p.role = 'trainee'
  p.status = 'active'
  p.name = 'Julia'
  p.last_name = 'Costa'
  p.gender = 'female'
  p.oab = '200.456 PR'
  p.rg = '888999000'
  p.cpf = '888.999.000-11'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('1998-07-20')
  p.mother_name = 'Patricia Costa'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Trainee)"
end

# Paralegal
user_paralegal = User.find_or_create_by!(email: 'pedro.santos@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_paralegal = UserProfile.find_or_create_by!(user: user_paralegal) do |p|
  p.role = 'paralegal'
  p.status = 'active'
  p.name = 'Pedro'
  p.last_name = 'Santos'
  p.gender = 'male'
  p.rg = '777888999'
  p.cpf = '777.888.999-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1990-11-05')
  p.mother_name = 'Rosa Santos'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Paralegal)"
end

# Secretary
user_secretary = User.find_or_create_by!(email: 'ana.secretaria@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_secretary = UserProfile.find_or_create_by!(user: user_secretary) do |p|
  p.role = 'secretary'
  p.status = 'active'
  p.name = 'Ana'
  p.last_name = 'Costa'
  p.gender = 'female'
  p.rg = '987654321'
  p.cpf = '987.654.321-00'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1995-03-10')
  p.mother_name = 'Maria Costa'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Secretary)"
end

# Counter (Accountant)
user_counter = User.find_or_create_by!(email: 'roberto.contador@pradoadvocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_principal
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_counter = UserProfile.find_or_create_by!(user: user_counter) do |p|
  p.role = 'counter'
  p.status = 'active'
  p.name = 'Roberto'
  p.last_name = 'Oliveira'
  p.gender = 'male'
  p.rg = '444555666'
  p.cpf = '444.555.666-77'
  p.nationality = 'brazilian'
  p.civil_status = 'divorced'
  p.birth = Date.parse('1982-09-12')
  p.mother_name = 'Lucia Oliveira'
  p.office = office_principal
  puts "  ✅ Created profile: #{p.full_name} (Counter)"
end

# Team Filial Users
user_filial_lawyer = User.find_or_create_by!(email: 'amanda.lawyer@silvasantos.adv.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_filial
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_filial_lawyer = UserProfile.find_or_create_by!(user: user_filial_lawyer) do |p|
  p.role = 'lawyer'
  p.status = 'active'
  p.name = 'Amanda'
  p.last_name = 'Ferreira'
  p.gender = 'female'
  p.oab = '222.333 SP'
  p.rg = '111222333'
  p.cpf = '111.222.333-44'
  p.nationality = 'brazilian'
  p.civil_status = 'single'
  p.birth = Date.parse('1991-06-30')
  p.mother_name = 'Teresa Ferreira'
  p.office = office_filial
  puts "  ✅ Created profile: #{p.full_name} (Filial Lawyer)"
end

UserOffice.find_or_create_by!(
  user_profile: profile_filial_lawyer,
  office: office_filial
) do |uo|
  uo.partnership_type = 'partner'
  uo.partnership_percentage = 50.0
  uo.joining_date = Date.parse('2020-01-15')
  puts "  ✅ Created partnership: #{profile_filial_lawyer.full_name} - 50% partner"
end

# Team Parceiro Users
user_parceiro_lawyer = User.find_or_create_by!(email: 'andre.costa@costaadv.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team_parceiro
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile_parceiro_lawyer = UserProfile.find_or_create_by!(user: user_parceiro_lawyer) do |p|
  p.role = 'lawyer'
  p.status = 'active'
  p.name = 'André'
  p.last_name = 'Costa'
  p.gender = 'male'
  p.oab = '98.765 RJ'
  p.rg = '333444555'
  p.cpf = '333.444.555-66'
  p.nationality = 'brazilian'
  p.civil_status = 'married'
  p.birth = Date.parse('1985-12-10')
  p.mother_name = 'Helena Costa'
  p.office = office_parceiro
  puts "  ✅ Created profile: #{p.full_name} (Partner Lawyer)"
end

UserOffice.find_or_create_by!(
  user_profile: profile_parceiro_lawyer,
  office: office_parceiro
) do |uo|
  uo.partnership_type = 'owner'
  uo.partnership_percentage = 100.0
  uo.joining_date = Date.parse('2022-06-01')
  puts "  ✅ Created ownership: #{profile_parceiro_lawyer.full_name} - 100% owner"
end

# ==========================================
# BANK ACCOUNTS
# ==========================================
puts '🏦 Creating Bank Accounts...'

# Office bank accounts
BankAccount.find_or_create_by!(
  accountable: office_principal,
  bank_name: 'Banco do Brasil'
) do |ba|
  ba.account_type = 'checking'
  ba.agency = '3033-5'
  ba.account_number = '123456-7'
  ba.account_holder = 'Prado & Associados Advocacia'
  ba.cpf_cnpj = office_principal.cnpj
  ba.is_primary = true
  puts "  ✅ Created bank account for office: #{office_principal.name}"
end

BankAccount.find_or_create_by!(
  accountable: office_principal,
  bank_name: 'Caixa Econômica Federal'
) do |ba|
  ba.account_type = 'savings'
  ba.agency = '0001'
  ba.account_number = '00123456-8'
  ba.account_holder = 'Prado & Associados Advocacia'
  ba.cpf_cnpj = office_principal.cnpj
  ba.is_primary = false
  puts "  ✅ Created savings account for office: #{office_principal.name}"
end

# User bank account
BankAccount.find_or_create_by!(
  accountable: profile_senior_partner,
  bank_name: 'Itaú'
) do |ba|
  ba.account_type = 'checking'
  ba.agency = '0912'
  ba.account_number = '54321-0'
  ba.account_holder = profile_senior_partner.full_name
  ba.cpf_cnpj = profile_senior_partner.cpf
  ba.is_primary = true
  puts "  ✅ Created bank account for user: #{profile_senior_partner.full_name}"
end

# ==========================================
# CUSTOMERS with Diverse Types and Capacities
# ==========================================
puts '👥 Creating Diverse Customers and ProfileCustomers...'

# Customer 1 - Fully Capable Individual
customer_capable = Customer.find_or_create_by!(email: 'carlos.oliveira@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_senior_partner.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_capable = ProfileCustomer.find_or_create_by!(customer: customer_capable) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Carlos'
  pc.last_name = 'Oliveira Santos'
  pc.cpf = '123.456.789-09'
  pc.rg = '1234567'
  pc.birth = Date.parse('1985-07-15')
  pc.gender = 'male'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.profession = 'Empresário'
  pc.mother_name = 'Maria Oliveira'
  pc.capacity = 'able' # Fully capable
  pc.status = 'active'
  pc.inss_password = 'INSS2024'
  pc.nit = '12345678901'
  pc.created_by_id = user_senior_partner.id
  puts "  ✅ Created profile customer: #{pc.full_name} (Capable)"
end

# Add multiple addresses
profile_customer_capable.addresses.find_or_create_by!(
  zip_code: '85810020',
  street: 'Rua Brasil',
  number: '100',
  address_type: 'main'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  puts "  ✅ Created main address for customer"
end

profile_customer_capable.addresses.find_or_create_by!(
  zip_code: '85810030',
  street: 'Rua Argentina',
  number: '200',
  address_type: 'correspondence'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  puts "  ✅ Created correspondence address for customer"
end

profile_customer_capable.phones.find_or_create_by!(phone_number: '4598765432') do |_p|
  puts "  ✅ Created phone for customer"
end

# Customer bank account
BankAccount.find_or_create_by!(
  accountable: profile_customer_capable,
  bank_name: 'Bradesco'
) do |ba|
  ba.account_type = 'checking'
  ba.agency = '1234'
  ba.account_number = '98765-4'
  ba.account_holder = profile_customer_capable.full_name
  ba.cpf_cnpj = profile_customer_capable.cpf
  ba.is_primary = true
  puts "  ✅ Created bank account for customer: #{profile_customer_capable.full_name}"
end

# Customer 2 - Large Company (Legal Person)
customer_company = Customer.find_or_create_by!(email: 'juridico@grandecorp.com.br') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_senior_partner.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_company = ProfileCustomer.find_or_create_by!(customer: customer_company) do |pc|
  pc.customer_type = 'legal_person'
  pc.name = 'Grande Corporação S.A.'
  pc.cnpj = '11.222.333/0001-44'
  pc.company = 'Grande Corporação S.A.'
  pc.cpf = '111.444.777-35' # Legal representative's CPF
  pc.rg = '5555555'
  pc.gender = 'male'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.profession = 'CEO'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user_senior_partner.id
  puts "  ✅ Created profile customer: #{pc.name} (Company)"
end

profile_customer_company.addresses.find_or_create_by!(
  zip_code: '01310200',
  street: 'Avenida Paulista',
  number: '2000',
  address_type: 'main'
) do |a|
  a.neighborhood = 'Bela Vista'
  a.city = 'São Paulo'
  a.state = 'SP'
  a.complement = 'Torre A, 25º andar'
  puts "  ✅ Created address for company"
end

profile_customer_company.phones.find_or_create_by!(phone_number: '1133445566') do |_p|
  puts "  ✅ Created phone for company"
end

# Customer 3 - Minor (Relatively Incapable)
customer_minor = Customer.find_or_create_by!(email: 'pedro.menor@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_junior_partner.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_minor = ProfileCustomer.find_or_create_by!(customer: customer_minor) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Pedro'
  pc.last_name = 'Silva Junior'
  pc.cpf = '111.222.333-96'
  pc.rg = '9876543'
  pc.birth = Date.parse('2008-12-01')
  pc.gender = 'male'
  pc.civil_status = 'single'
  pc.nationality = 'brazilian'
  pc.mother_name = 'Ana Silva'
  pc.profession = 'Estudante'
  pc.capacity = 'relatively' # Minor - relatively incapable
  pc.status = 'active'
  pc.created_by_id = user_junior_partner.id
  puts "  ✅ Created profile customer: #{pc.full_name} (Minor)"
end

# Customer 4 - Elderly with Guardian (Unable)
customer_elderly = Customer.find_or_create_by!(email: 'jose.senior@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_associate.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_elderly = ProfileCustomer.find_or_create_by!(customer: customer_elderly) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'José'
  pc.last_name = 'Ferreira da Silva'
  pc.cpf = '999.888.777-66'
  pc.rg = '1112223'
  pc.birth = Date.parse('1940-03-25')
  pc.gender = 'male'
  pc.civil_status = 'widowed'
  pc.nationality = 'brazilian'
  pc.mother_name = 'Maria Ferreira'
  pc.profession = 'Aposentado'
  pc.capacity = 'unable' # Unable - needs guardian
  pc.status = 'active'
  pc.number_benefit = 'BEN123456789' # Social security benefit number
  pc.created_by_id = user_associate.id
  puts "  ✅ Created profile customer: #{pc.full_name} (Unable)"
end

# Customer 5 - Deceased (for estate management)
customer_deceased = Customer.find_or_create_by!(email: 'espolio.antonio@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_senior_partner.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_deceased = ProfileCustomer.find_or_create_by!(customer: customer_deceased) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Espólio de Antonio'
  pc.last_name = 'Rodrigues'
  pc.cpf = '777.666.555-44'
  pc.rg = '7776665'
  pc.birth = Date.parse('1950-08-10')
  pc.gender = 'male'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.mother_name = 'Rosa Rodrigues'
  pc.profession = 'Empresário'
  pc.capacity = 'able'
  pc.status = 'deceased'
  pc.deceased_at = Date.parse('2023-12-01')
  pc.created_by_id = user_senior_partner.id
  puts "  ✅ Created profile customer: #{pc.full_name} (Deceased - Estate)"
end

# Customer 6 - Counter type (Professional partner)
customer_counter = Customer.find_or_create_by!(email: 'contador@contabilidade.com.br') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user_counter.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer_counter = ProfileCustomer.find_or_create_by!(customer: customer_counter) do |pc|
  pc.customer_type = 'counter' # Professional partner
  pc.name = 'Contabilidade Express'
  pc.cnpj = '88.999.777/0001-55'
  pc.company = 'Contabilidade Express LTDA'
  pc.cpf = '888.999.777-55'
  pc.profession = 'Contador'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user_counter.id
  puts "  ✅ Created profile customer: #{pc.name} (Counter/Professional)"
end

# Create representative relationships
Represent.find_or_create_by!(
  profile_customer: profile_customer_minor,
  representor: profile_customer_capable,
  team: team_principal
) do |r|
  r.relationship_type = 'parent'
  puts '  ✅ Created representative relationship: Parent for Minor'
end

Represent.find_or_create_by!(
  profile_customer: profile_customer_elderly,
  representor: profile_customer_capable,
  team: team_principal
) do |r|
  r.relationship_type = 'guardian'
  puts '  ✅ Created representative relationship: Guardian for Elderly'
end

Represent.find_or_create_by!(
  profile_customer: profile_customer_deceased,
  representor: profile_customer_capable,
  team: team_principal
) do |r|
  r.relationship_type = 'estate_administrator'
  puts '  ✅ Created representative relationship: Estate Administrator'
end

# ==========================================
# TEAM-CUSTOMER ASSOCIATIONS (Cross-team access)
# ==========================================
puts '🔗 Creating Team-Customer Associations to Demonstrate Isolation...'

# Team Principal has access to most customers
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_capable, customer_email: customer_capable.email)
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_company, customer_email: customer_company.email)
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_minor, customer_email: customer_minor.email)
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_elderly, customer_email: customer_elderly.email)
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_deceased, customer_email: customer_deceased.email)
TeamCustomer.find_or_create_by!(team: team_principal, customer: customer_counter, customer_email: customer_counter.email)

# Team Filial has access to some customers (shared clients)
TeamCustomer.find_or_create_by!(team: team_filial, customer: customer_company, customer_email: customer_company.email)
TeamCustomer.find_or_create_by!(team: team_filial, customer: customer_capable, customer_email: customer_capable.email)

# Team Parceiro has limited access (only one client)
TeamCustomer.find_or_create_by!(team: team_parceiro, customer: customer_company, customer_email: customer_company.email)

puts "  ✅ Created team-customer associations demonstrating isolation"

# ==========================================
# POWERS (Poderes para Procuração)
# ==========================================
puts '📜 Creating Powers...'
power_categories = {
  'administrative' => [
    'Representar perante órgãos públicos federais',
    'Representar perante órgãos públicos estaduais',
    'Representar perante órgãos públicos municipais',
    'Assinar documentos públicos',
    'Assinar documentos particulares',
    'Requerer certidões',
    'Protocolar documentos'
  ],
  'judicial' => [
    'Propor ações judiciais',
    'Defender em ações judiciais',
    'Recorrer em todas as instâncias',
    'Fazer acordos judiciais',
    'Desistir de ações',
    'Renunciar direitos',
    'Transigir',
    'Dar quitação'
  ],
  'financial' => [
    'Receber valores',
    'Dar quitação de valores',
    'Movimentar contas bancárias',
    'Assinar cheques',
    'Fazer transferências bancárias',
    'Contratar empréstimos',
    'Dar garantias'
  ],
  'special' => [
    'Substabelecer com reserva de poderes',
    'Substabelecer sem reserva de poderes',
    'Representar em assembleias',
    'Votar em assembleias',
    'Comprar imóveis',
    'Vender imóveis',
    'Constituir empresas'
  ]
}

power_categories.each do |category, descriptions|
  descriptions.each do |desc|
    Power.find_or_create_by!(description: desc) do |p|
      p.category = category
      p.is_base = ['Propor ações judiciais', 'Receber valores', 'Assinar documentos públicos'].include?(desc)
      puts "  ✅ Created power: #{p.description} (#{category})"
    end
  end
end

# ==========================================
# COMPREHENSIVE WORKS
# ==========================================
puts '📋 Creating Comprehensive Works with Financial Details...'

# Work 1 - Complex Family Law Case (Team Principal)
work_family = Work.find_or_create_by!(
  folder: 'FAM-2024-001',
  team: team_principal
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'FAM')
  w.number = 1001
  w.note = 'Divórcio litigioso com partilha de bens complexa. Imóveis avaliados em R$ 2.5 milhões.'
  w.status = 'in_progress'
  w.initial_atendee = profile_secretary.id
  w.responsible_lawyer = profile_senior_partner.id
  w.partner_lawyer = profile_junior_partner.id
  w.bachelor = profile_paralegal.id
  w.intern = profile_trainee.id
  w.lawsuit = true
  w.gain_projection = 'R$ 250.000,00' # Expected legal fees
  w.compensations_five_years = 'R$ 1.250.000,00' # Asset division projection
  w.compensations_service = 'R$ 50.000,00' # Service compensation
  w.created_by_id = user_senior_partner.id
  puts "  ✅ Created work: #{w.folder} - Complex Family Law"
end

CustomerWork.find_or_create_by!(work: work_family, profile_customer: profile_customer_capable)
UserProfileWork.find_or_create_by!(work: work_family, user_profile: profile_senior_partner)
UserProfileWork.find_or_create_by!(work: work_family, user_profile: profile_junior_partner)
UserProfileWork.find_or_create_by!(work: work_family, user_profile: profile_paralegal)
UserProfileWork.find_or_create_by!(work: work_family, user_profile: profile_trainee)

# Associate office with work
OfficeWork.find_or_create_by!(work: work_family, office: office_principal)

# Work 2 - Labor Case (Team Principal)
work_labor = Work.find_or_create_by!(
  folder: 'TRAB-2024-002',
  team: team_principal
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'RECL')
  w.number = 1002
  w.note = 'Reclamação trabalhista coletiva - 50 funcionários. Horas extras e adicional de periculosidade.'
  w.status = 'in_progress'
  w.initial_atendee = profile_secretary.id
  w.responsible_lawyer = profile_junior_partner.id
  w.partner_lawyer = profile_associate.id
  w.lawsuit = true
  w.gain_projection = 'R$ 150.000,00'
  w.compensations_five_years = 'R$ 3.000.000,00' # Total claim value
  w.created_by_id = user_junior_partner.id
  puts "  ✅ Created work: #{w.folder} - Labor Case"
end

CustomerWork.find_or_create_by!(work: work_labor, profile_customer: profile_customer_company)
UserProfileWork.find_or_create_by!(work: work_labor, user_profile: profile_junior_partner)
UserProfileWork.find_or_create_by!(work: work_labor, user_profile: profile_associate)
OfficeWork.find_or_create_by!(work: work_labor, office: office_principal)

# Work 3 - Social Security Case (Team Principal)
work_social_security = Work.find_or_create_by!(
  folder: 'PREV-2024-003',
  team: team_principal
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'APOI')
  w.number = 1003
  w.note = 'Aposentadoria por idade rural. Cliente trabalhou 35 anos em agricultura familiar.'
  w.status = 'in_progress'
  w.initial_atendee = profile_secretary.id
  w.responsible_lawyer = profile_associate.id
  w.lawsuit = false
  w.gain_projection = 'R$ 15.000,00'
  w.compensations_five_years = 'R$ 60.000,00' # Retroactive benefits
  w.created_by_id = user_associate.id
  puts "  ✅ Created work: #{w.folder} - Social Security"
end

CustomerWork.find_or_create_by!(work: work_social_security, profile_customer: profile_customer_elderly)
UserProfileWork.find_or_create_by!(work: work_social_security, user_profile: profile_associate)
OfficeWork.find_or_create_by!(work: work_social_security, office: office_principal)

# Work 4 - Estate/Succession Case (Team Principal)
work_estate = Work.find_or_create_by!(
  folder: 'SUC-2024-004',
  team: team_principal
) do |w|
  w.procedure = 'extrajudicial'
  w.law_area = LawArea.find_by(code: 'SUC')
  w.number = 1004
  w.note = 'Inventário extrajudicial. Patrimônio: 3 imóveis, contas bancárias, investimentos.'
  w.status = 'in_progress'
  w.initial_atendee = profile_secretary.id
  w.responsible_lawyer = profile_senior_partner.id
  w.partner_lawyer = profile_junior_partner.id
  w.lawsuit = false
  w.gain_projection = 'R$ 80.000,00'
  w.compensations_five_years = 'R$ 4.000.000,00' # Estate value
  w.created_by_id = user_senior_partner.id
  puts "  ✅ Created work: #{w.folder} - Estate/Succession"
end

CustomerWork.find_or_create_by!(work: work_estate, profile_customer: profile_customer_deceased)
UserProfileWork.find_or_create_by!(work: work_estate, user_profile: profile_senior_partner)
UserProfileWork.find_or_create_by!(work: work_estate, user_profile: profile_junior_partner)
OfficeWork.find_or_create_by!(work: work_estate, office: office_principal)

# Work 5 - Criminal Defense (Team Filial)
work_criminal = Work.find_or_create_by!(
  folder: 'CRIM-2024-001',
  team: team_filial
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'CRIM')
  w.number = 2001
  w.note = 'Defesa criminal - Crime tributário. Cliente acusado de sonegação fiscal.'
  w.status = 'in_progress'
  w.initial_atendee = profile_filial_lawyer.id
  w.responsible_lawyer = profile_filial_lawyer.id
  w.lawsuit = true
  w.gain_projection = 'R$ 100.000,00'
  w.created_by_id = user_filial_lawyer.id
  puts "  ✅ Created work: #{w.folder} - Criminal Defense (Team Filial)"
end

CustomerWork.find_or_create_by!(work: work_criminal, profile_customer: profile_customer_company)
UserProfileWork.find_or_create_by!(work: work_criminal, user_profile: profile_filial_lawyer)
OfficeWork.find_or_create_by!(work: work_criminal, office: office_filial)

# Work 6 - Tax Case (Team Parceiro)
work_tax = Work.find_or_create_by!(
  folder: 'TRIB-2024-001',
  team: team_parceiro
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'IPTU')
  w.number = 3001
  w.note = 'Revisão de IPTU - Imóvel comercial superavaliado pela prefeitura.'
  w.status = 'in_progress'
  w.initial_atendee = profile_parceiro_lawyer.id
  w.responsible_lawyer = profile_parceiro_lawyer.id
  w.lawsuit = false
  w.gain_projection = 'R$ 20.000,00'
  w.compensations_five_years = 'R$ 100.000,00' # Tax savings
  w.created_by_id = user_parceiro_lawyer.id
  puts "  ✅ Created work: #{w.folder} - Tax Case (Team Parceiro)"
end

CustomerWork.find_or_create_by!(work: work_tax, profile_customer: profile_customer_company)
UserProfileWork.find_or_create_by!(work: work_tax, user_profile: profile_parceiro_lawyer)
OfficeWork.find_or_create_by!(work: work_tax, office: office_parceiro)

# Work 7 - Archived Case (Team Principal)
work_archived = Work.find_or_create_by!(
  folder: 'CIV-2023-100',
  team: team_principal
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'DANO')
  w.number = 100
  w.note = 'Ação de danos morais - Caso concluído com acordo favorável.'
  w.status = 'archived'
  w.initial_atendee = profile_secretary.id
  w.responsible_lawyer = profile_associate.id
  w.lawsuit = true
  w.gain_projection = 'R$ 30.000,00'
  w.compensations_service = 'R$ 150.000,00' # Settlement amount
  w.created_by_id = user_associate.id
  puts "  ✅ Created work: #{w.folder} - Archived Case"
end

CustomerWork.find_or_create_by!(work: work_archived, profile_customer: profile_customer_capable)
UserProfileWork.find_or_create_by!(work: work_archived, user_profile: profile_associate)
OfficeWork.find_or_create_by!(work: work_archived, office: office_principal)

# ==========================================
# COMPREHENSIVE JOBS
# ==========================================
puts '📝 Creating Comprehensive Jobs with Different Priorities and Statuses...'

# Jobs for Family Law Case
job_family_1 = Job.find_or_create_by!(
  description: 'Elaborar petição inicial do divórcio',
  work: work_family
) do |j|
  j.deadline = 3.days.from_now
  j.status = 'completed'
  j.priority = 'high'
  j.comment = 'Incluir pedido de tutela antecipada para partilha provisória'
  j.team = team_principal
  j.profile_customer = profile_customer_capable
  j.created_by_id = user_senior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_family_1, user_profile: profile_senior_partner, role: 'assignee')

job_family_2 = Job.find_or_create_by!(
  description: 'Reunir documentação patrimonial do casal',
  work: work_family
) do |j|
  j.deadline = 7.days.from_now
  j.status = 'in_progress'
  j.priority = 'high'
  j.comment = 'Solicitar extratos bancários dos últimos 5 anos'
  j.team = team_principal
  j.profile_customer = profile_customer_capable
  j.created_by_id = user_senior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_family_2, user_profile: profile_paralegal, role: 'assignee')
JobUserProfile.find_or_create_by!(job: job_family_2, user_profile: profile_secretary, role: 'collaborator')

job_family_3 = Job.find_or_create_by!(
  description: 'Agendar audiência de conciliação',
  work: work_family
) do |j|
  j.deadline = 14.days.from_now
  j.status = 'pending'
  j.priority = 'medium'
  j.comment = 'Verificar disponibilidade do cliente e advogado da parte contrária'
  j.team = team_principal
  j.created_by_id = user_junior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_family_3, user_profile: profile_secretary, role: 'assignee')

# Jobs for Labor Case
job_labor_1 = Job.find_or_create_by!(
  description: 'Coletar depoimentos dos 50 funcionários',
  work: work_labor
) do |j|
  j.deadline = 10.days.from_now
  j.status = 'in_progress'
  j.priority = 'high'
  j.comment = 'Organizar reuniões por departamento para otimizar tempo'
  j.team = team_principal
  j.profile_customer = profile_customer_company
  j.created_by_id = user_junior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_labor_1, user_profile: profile_trainee, role: 'assignee')
JobUserProfile.find_or_create_by!(job: job_labor_1, user_profile: profile_paralegal, role: 'collaborator')

job_labor_2 = Job.find_or_create_by!(
  description: 'Calcular valores devidos de horas extras',
  work: work_labor
) do |j|
  j.deadline = 5.days.from_now
  j.status = 'pending'
  j.priority = 'high'
  j.comment = 'Usar planilha padrão do escritório. Considerar DSR e reflexos.'
  j.team = team_principal
  j.created_by_id = user_associate.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_labor_2, user_profile: profile_counter, role: 'assignee')

# Jobs for Social Security Case
job_social_1 = Job.find_or_create_by!(
  description: 'Protocolar requerimento administrativo no INSS',
  work: work_social_security
) do |j|
  j.deadline = 2.days.from_now
  j.status = 'pending'
  j.priority = 'urgent'
  j.comment = 'Cliente precisa começar a receber o benefício urgentemente'
  j.team = team_principal
  j.profile_customer = profile_customer_elderly
  j.created_by_id = user_associate.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_social_1, user_profile: profile_associate, role: 'assignee')

job_social_2 = Job.find_or_create_by!(
  description: 'Reunir documentos comprobatórios de trabalho rural',
  work: work_social_security
) do |j|
  j.deadline = 7.days.from_now
  j.status = 'in_progress'
  j.priority = 'high'
  j.comment = 'Incluir declarações de sindicato, notas de produtor, testemunhas'
  j.team = team_principal
  j.profile_customer = profile_customer_elderly
  j.created_by_id = user_associate.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_social_2, user_profile: profile_paralegal, role: 'assignee')

# Jobs for Estate Case
job_estate_1 = Job.find_or_create_by!(
  description: 'Realizar avaliação dos imóveis do espólio',
  work: work_estate
) do |j|
  j.deadline = 15.days.from_now
  j.status = 'pending'
  j.priority = 'medium'
  j.comment = 'Contratar avaliador credenciado. 3 imóveis em Cascavel-PR.'
  j.team = team_principal
  j.profile_customer = profile_customer_deceased
  j.created_by_id = user_senior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_estate_1, user_profile: profile_junior_partner, role: 'assignee')

job_estate_2 = Job.find_or_create_by!(
  description: 'Elaborar minuta de partilha amigável',
  work: work_estate
) do |j|
  j.deadline = 20.days.from_now
  j.status = 'pending'
  j.priority = 'low'
  j.comment = 'Aguardar conclusão das avaliações. 4 herdeiros necessários.'
  j.team = team_principal
  j.created_by_id = user_senior_partner.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_estate_2, user_profile: profile_senior_partner, role: 'assignee')

# Jobs for Criminal Case (Team Filial)
job_criminal_1 = Job.find_or_create_by!(
  description: 'Preparar defesa prévia',
  work: work_criminal
) do |j|
  j.deadline = 10.days.from_now
  j.status = 'in_progress'
  j.priority = 'urgent'
  j.comment = 'Prazo penal - imperdível! Argumentar ausência de dolo.'
  j.team = team_filial
  j.profile_customer = profile_customer_company
  j.created_by_id = user_filial_lawyer.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_criminal_1, user_profile: profile_filial_lawyer, role: 'assignee')

# Jobs for Tax Case (Team Parceiro)
job_tax_1 = Job.find_or_create_by!(
  description: 'Protocolar recurso administrativo contra lançamento IPTU',
  work: work_tax
) do |j|
  j.deadline = 30.days.from_now
  j.status = 'pending'
  j.priority = 'medium'
  j.comment = 'Anexar laudo de avaliação contradizendo valor venal'
  j.team = team_parceiro
  j.profile_customer = profile_customer_company
  j.created_by_id = user_parceiro_lawyer.id
  puts "  ✅ Created job: #{j.description}"
end
JobUserProfile.find_or_create_by!(job: job_tax_1, user_profile: profile_parceiro_lawyer, role: 'assignee')

# Overdue job example
job_overdue = Job.find_or_create_by!(
  description: 'Apresentar contrarrazões ao recurso',
  work: work_family
) do |j|
  j.deadline = 2.days.ago
  j.status = 'pending'
  j.priority = 'urgent'
  j.comment = 'ATRASADO! Verificar possibilidade de protocolo ainda hoje.'
  j.team = team_principal
  j.created_by_id = user_senior_partner.id
  puts "  ✅ Created job: #{j.description} (OVERDUE)"
end
JobUserProfile.find_or_create_by!(job: job_overdue, user_profile: profile_senior_partner, role: 'assignee')

# ==========================================
# FINAL STATISTICS
# ==========================================
puts '=' * 50
puts '✅ Enhanced seed completed successfully!'
puts '📊 Database Statistics:'
puts "\n🏢 Teams & Offices:"
puts "  - Teams: #{Team.count}"
puts "  - Offices: #{Office.count}"
puts "    - Individual: #{Office.where(society: 'individual').count}"
puts "    - Simple: #{Office.where(society: 'simple').count}"
puts "    - Company: #{Office.where(society: 'company').count}"
puts "  - Office Addresses: #{Address.where(addressable_type: 'Office').count}"
puts "  - Office Phones: #{Phone.where(phoneable_type: 'Office').count}"

puts "\n👥 Users & Profiles:"
puts "  - Users: #{User.count}"
puts "  - User Profiles: #{UserProfile.count}"
puts "    - Lawyers: #{UserProfile.where(role: 'lawyer').count}"
puts "    - Trainees: #{UserProfile.where(role: 'trainee').count}"
puts "    - Paralegals: #{UserProfile.where(role: 'paralegal').count}"
puts "    - Secretaries: #{UserProfile.where(role: 'secretary').count}"
puts "    - Counters: #{UserProfile.where(role: 'counter').count}"
puts "  - User-Office Partnerships: #{UserOffice.count}"

puts "\n👤 Customers:"
puts "  - Customers: #{Customer.count}"
puts "  - Profile Customers: #{ProfileCustomer.count}"
puts "    - Physical Persons: #{ProfileCustomer.where(customer_type: 'physical_person').count}"
puts "    - Legal Persons: #{ProfileCustomer.where(customer_type: 'legal_person').count}"
puts "    - Counters: #{ProfileCustomer.where(customer_type: 'counter').count}"
puts "  - Customer Capacities:"
puts "    - Able: #{ProfileCustomer.where(capacity: 'able').count}"
puts "    - Relatively Incapable: #{ProfileCustomer.where(capacity: 'relatively').count}"
puts "    - Unable: #{ProfileCustomer.where(capacity: 'unable').count}"
puts "  - Deceased Customers: #{ProfileCustomer.where(status: 'deceased').count}"
puts "  - Representative Relationships: #{Represent.count}"
puts "  - Customer Addresses: #{Address.where(addressable_type: 'ProfileCustomer').count}"
puts "  - Customer Phones: #{Phone.where(phoneable_type: 'ProfileCustomer').count}"

puts "\n🔗 Team Isolation:"
puts "  - Team-Customer Associations: #{TeamCustomer.count}"
puts "    - Team Principal customers: #{TeamCustomer.where(team: team_principal).count}"
puts "    - Team Filial customers: #{TeamCustomer.where(team: team_filial).count}"
puts "    - Team Parceiro customers: #{TeamCustomer.where(team: team_parceiro).count}"

puts "\n📋 Work & Jobs:"
puts "  - Law Areas: #{LawArea.count}"
puts "    - System Areas: #{LawArea.where(created_by_team_id: nil).count}"
puts "    - Team-specific Areas: #{LawArea.where.not(created_by_team_id: nil).count}"
puts "  - Works: #{Work.count}"
puts "    - In Progress: #{Work.where(status: 'in_progress').count}"
puts "    - Archived: #{Work.where(status: 'archived').count}"
puts "  - Jobs: #{Job.count}"
puts "    - Pending: #{Job.where(status: 'pending').count}"
puts "    - In Progress: #{Job.where(status: 'in_progress').count}"
puts "    - Completed: #{Job.where(status: 'completed').count}"
puts "    - Overdue: #{Job.where('deadline < ?', Time.current).where(status: 'pending').count}"

puts "\n💰 Financial:"
puts "  - Bank Accounts: #{BankAccount.count}"
puts "    - Office Accounts: #{BankAccount.where(accountable_type: 'Office').count}"
puts "    - User Accounts: #{BankAccount.where(accountable_type: 'UserProfile').count}"
puts "    - Customer Accounts: #{BankAccount.where(accountable_type: 'ProfileCustomer').count}"
puts "  - Powers: #{Power.count}"
puts "    - Categories: #{Power.distinct.pluck(:category).join(', ')}"

puts '=' * 50

puts "\n📧 Test Credentials by Team:"
puts "\n🏢 Team Principal (subdomain: principal):"
puts 'Staff:'
puts '  - Senior Partner: joao.prado@pradoadvocacia.com.br | Password123!'
puts '  - Junior Partner: maria.silva@pradoadvocacia.com.br | Password123!'
puts '  - Associate: carlos.mendes@pradoadvocacia.com.br | Password123!'
puts '  - Trainee: julia.costa@pradoadvocacia.com.br | Password123!'
puts '  - Paralegal: pedro.santos@pradoadvocacia.com.br | Password123!'
puts '  - Secretary: ana.secretaria@pradoadvocacia.com.br | Password123!'
puts '  - Counter: roberto.contador@pradoadvocacia.com.br | Password123!'

puts "\n🏢 Team Filial (subdomain: filial-sp):"
puts '  - Lawyer: amanda.lawyer@silvasantos.adv.br | Password123!'

puts "\n🏢 Team Parceiro (subdomain: parceiro-rj):"
puts '  - Lawyer: andre.costa@costaadv.com.br | Password123!'

puts "\nCustomers:"
puts '  - Capable Individual: carlos.oliveira@gmail.com | ClientPass123!'
puts '  - Large Company: juridico@grandecorp.com.br | ClientPass123!'
puts '  - Minor (w/ representative): pedro.menor@gmail.com | ClientPass123!'
puts '  - Elderly (w/ guardian): jose.senior@gmail.com | ClientPass123!'
puts '  - Estate: espolio.antonio@gmail.com | ClientPass123!'
puts '  - Counter/Professional: contador@contabilidade.com.br | ClientPass123!'

puts "\n🔐 System Isolation Features Demonstrated:"
puts '  ✅ Multi-team setup with separate subdomains'
puts '  ✅ Team-specific settings and configurations'
puts '  ✅ Cross-team customer access (shared clients)'
puts '  ✅ Team-specific law areas'
puts '  ✅ Different office types and accounting methods'
puts '  ✅ Partnership percentages and types'
puts '  ✅ Various user roles with different permissions'
puts '  ✅ Customer capacity system (able/relatively/unable)'
puts '  ✅ Representative relationships (parent/guardian/estate)'
puts '  ✅ Comprehensive financial tracking'
puts '  ✅ Multiple address and contact types'
puts '  ✅ Complete work lifecycle with jobs'