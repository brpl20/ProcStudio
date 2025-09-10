# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

puts '🌱 Starting seed process...'
puts '=' * 50

# ==========================================
# TEAMS
# ==========================================
puts '📁 Creating Teams...'
team = Team.find_or_create_by!(name: 'Escritório Principal') do |t|
  t.subdomain = 'principal'
  puts "  ✅ Created team: #{t.name}"
end

team2 = Team.find_or_create_by!(name: 'Escritório Filial') do |t|
  t.subdomain = 'filial'
  puts "  ✅ Created team: #{t.name}"
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
  { code: 'OUTROS', name: 'Outros', parent: nil },

  # Sub-areas for Cível
  { code: 'FAM', name: 'Família', parent: 'CIV' },
  { code: 'CONS', name: 'Consumidor', parent: 'CIV' },
  { code: 'DANO', name: 'Danos Morais', parent: 'CIV' },

  # Sub-areas for Tributário
  { code: 'ASF', name: 'Asfalto', parent: 'TRIB' },
  { code: 'ALV', name: 'Alvará', parent: 'TRIB' },
  { code: 'PIS', name: 'PIS/COFINS', parent: 'TRIB' },

  # Sub-areas for Previdenciário
  { code: 'APOT', name: 'Aposentadoria por Tempo', parent: 'PREV' },
  { code: 'APOI', name: 'Aposentadoria por Idade', parent: 'PREV' },
  { code: 'APOR', name: 'Aposentadoria Rural', parent: 'PREV' },
  { code: 'INV', name: 'Invalidez', parent: 'PREV' },
  { code: 'REV', name: 'Revisão de Benefício', parent: 'PREV' },

  # Sub-area for Trabalhista
  { code: 'RECL', name: 'Reclamatória Trabalhista', parent: 'TRAB' }
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

# ==========================================
# OFFICE TYPES - REMOVED (no longer using office_type)
# ==========================================
# puts '🏢 Creating Office Types...'
# office_types = ['Advocacia', 'Consultoria', 'Contabilidade']
# office_types.each do |type_name|
#   OfficeType.find_or_create_by!(description: type_name) do |ot|
#     puts "  ✅ Created office type: #{ot.description}"
#   end
# end

# ==========================================
# OFFICES
# ==========================================
puts '🏢 Creating Offices...'
office1 = Office.find_or_create_by!(cnpj: '49.609.519/0001-60') do |o|
  o.name = 'Escritório Advocacia Principal'
  o.oab_id = '15.074 PR'
  o.society = 'individual'
  o.foundation = Date.parse('2023-09-25')
  o.site = 'advocacia.com.br'
  # o.office_type_id = OfficeType.find_by(description: 'Advocacia').id # office_type removed
  o.team = team
  puts "  ✅ Created office: #{o.name}"
end

# Add address for office1
office1.addresses.find_or_create_by!(
  zip_code: '85810010',
  street: 'Rua Paraná',
  number: '3033'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  a.address_type = 'main'
  puts "  ✅ Created address for office: #{office1.name}"
end

# Add phone for office1
office1.phones.find_or_create_by!(
  phone_number: '4532259000'
) do |_p|
  puts "  ✅ Created phone for office: #{office1.name}"
end

office2 = Office.find_or_create_by!(cnpj: '11.222.333/0001-81') do |o|
  o.name = 'Escritório Advocacia Secundário'
  o.oab_id = '12.345 SP'
  o.society = 'company'
  o.foundation = Date.parse('2020-01-15')
  o.site = 'advocacia2.com.br'
  # o.office_type_id = OfficeType.find_by(description: 'Advocacia').id # office_type removed
  o.team = team2
  puts "  ✅ Created office: #{o.name}"
end

# Add address for office2
office2.addresses.find_or_create_by!(
  zip_code: '01310100',
  street: 'Avenida Paulista',
  number: '1500'
) do |a|
  a.neighborhood = 'Bela Vista'
  a.city = 'São Paulo'
  a.state = 'SP'
  a.address_type = 'main'
  puts "  ✅ Created address for office: #{office2.name}"
end

# Add phone for office2
office2.phones.find_or_create_by!(
  phone_number: '1132847000'
) do |_p|
  puts "  ✅ Created phone for office: #{office2.name}"
end

# ==========================================
# USERS (Lawyers/Staff)
# ==========================================
puts '👤 Creating Users and UserProfiles...'

# User 1 - Main Lawyer
user1 = User.find_or_create_by!(email: 'joao.prado@advocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile1 = UserProfile.find_or_create_by!(user: user1) do |p|
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
  p.birth = Date.parse('1991-10-16')
  p.mother_name = 'Rosinha Mendes Prado'
  p.office = office1
  puts "  ✅ Created profile: #{p.full_name}"
end

# User 2 - Associate Lawyer
user2 = User.find_or_create_by!(email: 'maria.silva@advocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile2 = UserProfile.find_or_create_by!(user: user2) do |p|
  p.role = 'lawyer'
  p.status = 'active'
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
  puts "  ✅ Created profile: #{p.full_name}"
end

# User 3 - Secretary
user3 = User.find_or_create_by!(email: 'ana.secretaria@advocacia.com.br') do |u|
  u.password = 'Password123!'
  u.password_confirmation = 'Password123!'
  u.team = team
  u.status = 'active'
  puts "  ✅ Created user: #{u.email}"
end

profile3 = UserProfile.find_or_create_by!(user: user3) do |p|
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
  p.office = office1
  puts "  ✅ Created profile: #{p.full_name}"
end

# ==========================================
# CUSTOMERS AND PROFILE CUSTOMERS
# ==========================================
puts '👥 Creating Customers and ProfileCustomers...'

# Customer 1 - Individual
customer1 = Customer.find_or_create_by!(email: 'cliente1@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer1 = ProfileCustomer.find_or_create_by!(customer: customer1) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Carlos'
  pc.last_name = 'Oliveira Santos'
  pc.cpf = '123.456.789-09' # Valid test CPF
  pc.rg = '1234567'
  pc.birth = Date.parse('1985-07-15')
  pc.gender = 'male'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.profession = 'Empresário'
  pc.mother_name = 'Maria Oliveira'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user1.id
  puts "  ✅ Created profile customer: #{pc.full_name}"
end

# Add address for customer 1 using polymorphic association
profile_customer1.addresses.find_or_create_by!(
  zip_code: '85810020',
  street: 'Rua Brasil',
  number: '100'
) do |a|
  a.neighborhood = 'Centro'
  a.city = 'Cascavel'
  a.state = 'PR'
  a.address_type = 'main'
  puts "  ✅ Created address for customer: #{profile_customer1.full_name}"
end

# Add phone for customer 1
profile_customer1.phones.find_or_create_by!(
  phone_number: '4598765432'
) do |_p|
  puts "  ✅ Created phone for customer: #{profile_customer1.full_name}"
end

# Customer 2 - Company
customer2 = Customer.find_or_create_by!(email: 'empresa@empresa.com.br') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer2 = ProfileCustomer.find_or_create_by!(customer: customer2) do |pc|
  pc.customer_type = 'legal_person'
  pc.name = 'Empresa Exemplo LTDA'
  pc.cnpj = '11.222.333/0001-44'
  pc.company = 'Empresa Exemplo LTDA'
  pc.cpf = '111.444.777-35' # Representative's CPF - valid test
  pc.rg = '5555555' # Representative's RG
  pc.gender = 'male'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.profession = 'Diretor Executivo'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user1.id
  puts "  ✅ Created profile customer: #{pc.name}"
end

# Add address for customer 2 using polymorphic association
profile_customer2.addresses.find_or_create_by!(
  zip_code: '01310200',
  street: 'Avenida Paulista',
  number: '2000'
) do |a|
  a.neighborhood = 'Bela Vista'
  a.city = 'São Paulo'
  a.state = 'SP'
  a.address_type = 'main'
  puts "  ✅ Created address for customer: #{profile_customer2.name}"
end

# Add phone for customer 2
profile_customer2.phones.find_or_create_by!(
  phone_number: '1133445566'
) do |_p|
  puts "  ✅ Created phone for customer: #{profile_customer2.name}"
end

# Customer 3 - Individual with representative
customer3 = Customer.find_or_create_by!(email: 'cliente.menor@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user2.id
  puts "  ✅ Created customer: #{c.email}"
end

profile_customer3 = ProfileCustomer.find_or_create_by!(customer: customer3) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Pedro'
  pc.last_name = 'Silva Junior'
  pc.cpf = '111.222.333-96' # Valid test CPF
  pc.rg = '9876543'
  pc.birth = Date.parse('2008-12-01')
  pc.gender = 'male'
  pc.civil_status = 'single'
  pc.nationality = 'brazilian'
  pc.mother_name = 'Ana Silva'
  pc.profession = 'Estudante'
  pc.capacity = 'relatively'
  pc.status = 'active'
  pc.created_by_id = user2.id
  puts "  ✅ Created profile customer: #{pc.full_name}"
end

# Create representative for minor
Represent.find_or_create_by!(
  profile_customer: profile_customer3,
  representor: profile_customer1,
  team: team
) do |_r|
  puts '  ✅ Created representative relationship'
end

# Associate customers with teams
TeamCustomer.find_or_create_by!(team: team, customer: customer1, customer_email: customer1.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer2, customer_email: customer2.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer3, customer_email: customer3.email)
TeamCustomer.find_or_create_by!(team: team2, customer: customer1, customer_email: customer1.email)

# ==========================================
# POWERS (Poderes para Procuração)
# ==========================================
puts '📜 Creating Powers...'
power_descriptions = [
  'Representar perante órgãos públicos',
  'Assinar documentos',
  'Receber valores',
  'Dar quitação',
  'Propor ações judiciais',
  'Fazer acordos',
  'Recorrer em todas as instâncias',
  'Substabelecer com reserva de poderes'
]

power_descriptions.map do |desc|
  Power.find_or_create_by!(description: desc) do |p|
    p.category = 'administrative'
    p.is_base = true
    puts "  ✅ Created power: #{p.description}"
  end
end

# ==========================================
# SAMPLE WORKS
# ==========================================
puts '📋 Creating Sample Works...'

# Work 1 - Active Civil Case
work1 = Work.find_or_create_by!(
  folder: 'PROC-2024-001',
  team: team
) do |w|
  w.procedure = 'judicial'
  w.law_area = LawArea.find_by(code: 'FAM')
  w.number = 1001
  w.note = 'Caso de divórcio consensual'
  w.status = 'in_progress'
  w.initial_atendee = profile1.id
  w.responsible_lawyer = profile1.id
  w.partner_lawyer = profile2.id
  w.created_by_id = user1.id
  puts "  ✅ Created work: #{w.folder}"
end

# Associate customers with work
CustomerWork.find_or_create_by!(work: work1, profile_customer: profile_customer1)

# Associate user profiles with work
UserProfileWork.find_or_create_by!(work: work1, user_profile: profile1)
UserProfileWork.find_or_create_by!(work: work1, user_profile: profile2)

# Work 2 - Labor Case
work2 = Work.find_or_create_by!(
  folder: 'PROC-2024-002',
  team: team
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'TRAB')
  w.number = 1002
  w.note = 'Reclamação trabalhista - horas extras'
  w.status = 'in_progress'
  w.initial_atendee = profile2.id
  w.responsible_lawyer = profile2.id
  w.lawsuit = true
  w.gain_projection = 'R$ 50.000,00'
  w.created_by_id = user2.id
  puts "  ✅ Created work: #{w.folder}"
end

CustomerWork.find_or_create_by!(work: work2, profile_customer: profile_customer2)
UserProfileWork.find_or_create_by!(work: work2, user_profile: profile2)

# Work 3 - Social Security Case (Archived)
work3 = Work.find_or_create_by!(
  folder: 'PROC-2023-100',
  team: team
) do |w|
  w.procedure = 'administrative'
  w.law_area = LawArea.find_by(code: 'APOI')
  w.number = 100
  w.note = 'Aposentadoria por idade - processo concluído'
  w.status = 'archived'
  w.initial_atendee = profile1.id
  w.responsible_lawyer = profile1.id
  w.created_by_id = user1.id
  puts "  ✅ Created work: #{w.folder}"
end

CustomerWork.find_or_create_by!(work: work3, profile_customer: profile_customer3)
UserProfileWork.find_or_create_by!(work: work3, user_profile: profile1)

# ==========================================
# JOBS (Tasks)
# ==========================================
puts '📝 Creating Jobs...'
job1 = Job.find_or_create_by!(
  description: 'Preparar petição inicial',
  work: work1
) do |j|
  j.deadline = 7.days.from_now
  j.status = 'pending'
  j.priority = 'high'
  j.comment = 'Urgente - prazo processual'
  j.team = team
  j.created_by_id = user1.id
  puts "  ✅ Created job: #{j.description}"
end

# Associate user profile with job
JobUserProfile.find_or_create_by!(job: job1, user_profile: profile1, role: 'assignee')

job2 = Job.find_or_create_by!(
  description: 'Coletar documentos do cliente',
  work: work2
) do |j|
  j.deadline = 3.days.from_now
  j.status = 'pending'
  j.priority = 'medium'
  j.profile_customer = profile_customer2
  j.team = team
  j.created_by_id = user2.id
  puts "  ✅ Created job: #{j.description}"
end

# Associate user profile with job
JobUserProfile.find_or_create_by!(job: job2, user_profile: profile3, role: 'assignee')

# ==========================================
# FINAL STATS
# ==========================================
puts '=' * 50
puts '✅ Seed completed successfully!'
puts '📊 Database Statistics:'
puts "  - Teams: #{Team.count}"
puts "  - Law Areas: #{LawArea.count}"
puts "  - Offices: #{Office.count}"
puts "  - Office Addresses: #{Address.where(addressable_type: 'Office').count}"
puts "  - Office Phones: #{Phone.where(phoneable_type: 'Office').count}"
puts "  - Customer Addresses: #{Address.where(addressable_type: 'ProfileCustomer').count}"
puts "  - Customer Phones: #{Phone.where(phoneable_type: 'ProfileCustomer').count}"
puts "  - Users: #{User.count}"
puts "  - User Profiles: #{UserProfile.count}"
puts "  - Customers: #{Customer.count}"
puts "  - Profile Customers: #{ProfileCustomer.count}"
puts "  - Works: #{Work.count}"
puts "  - Jobs: #{Job.count}"
puts "  - Powers: #{Power.count}"
puts '=' * 50

puts "\n📧 Test Credentials:"
puts 'Lawyers/Staff:'
puts '  - Email: joao.prado@advocacia.com.br | Password: Password123!'
puts '  - Email: maria.silva@advocacia.com.br | Password: Password123!'
puts '  - Email: ana.secretaria@advocacia.com.br | Password: Password123!'
puts "\nCustomers:"
puts '  - Email: cliente1@gmail.com | Password: ClientPass123!'
puts '  - Email: empresa@empresa.com.br | Password: ClientPass123!'
puts '  - Email: cliente.menor@gmail.com | Password: ClientPass123!'
