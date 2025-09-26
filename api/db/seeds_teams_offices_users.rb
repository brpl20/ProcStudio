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
# user3 = User.find_or_create_by!(email: 'ana.secretaria@advocacia.com.br') do |u|
#   u.password = 'Password123!'
#   u.password_confirmation = 'Password123!'
#   u.team = team
#   u.status = 'active'
#   puts "  ✅ Created user: #{u.email}"
# end

# profile3 = UserProfile.find_or_create_by!(user: user3) do |p|
#   p.role = 'secretary'
#   p.status = 'active'
#   p.name = 'Ana'
#   p.last_name = 'Costa'
#   p.gender = 'female'
#   p.rg = '987654321'
#   p.cpf = '987.654.321-00'
#   p.nationality = 'brazilian'
#   p.civil_status = 'married'
#   p.birth = Date.parse('1995-03-10')
#   p.mother_name = 'Maria Costa'
#   p.office = office1
#   puts "  ✅ Created profile: #{p.full_name}"
# end

# ==========================================
# FINAL STATS
# ==========================================
puts '=' * 50
puts '✅ Seed completed successfully!'
