# Seed file for testing the new polymorphic Customer structure
# Creates Customers with IndividualEntity and LegalEntity profiles
# Creates LegalEntityOffice records for law firms

require 'faker'

puts "=" * 80
puts "Starting Polymorphic Customer Seeds"
puts "=" * 80

# Helper method to generate valid CPF (Brazilian tax ID for individuals)
def generate_cpf
  digits = Array.new(9) { rand(0..9) }
  
  # Calculate first check digit
  sum = digits.each_with_index.reduce(0) { |s, (d, i)| s + d * (10 - i) }
  first_check = (sum * 10 % 11) % 10
  digits << first_check
  
  # Calculate second check digit
  sum = digits.each_with_index.reduce(0) { |s, (d, i)| s + d * (11 - i) }
  second_check = (sum * 10 % 11) % 10
  digits << second_check
  
  digits.join
end

# Helper method to generate valid CNPJ (Brazilian tax ID for companies)
def generate_cnpj
  # Simplified CNPJ generation - in production use a proper generator
  base = Array.new(8) { rand(0..9) }
  base += [0, 0, 0, 1] # Branch number
  
  # Add check digits (simplified)
  base += [rand(0..9), rand(0..9)]
  
  base.join
end

# Ensure we have at least one team
team = Team.first || Team.create!(
  name: "Default Team",
  subdomain: "default",
  owner_admin: Admin.first || Admin.create!(
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
)

puts "\nUsing team: #{team.name}"

# Get or create an admin for lawyer relationships
admin = Admin.first
if admin.nil?
  puts "Creating admin for lawyer relationships..."
  admin = Admin.create!(
    email: "lawyer.admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    status: "active"
  )
end

# Check if admin has an IndividualEntity through ProfileAdmin
profile_admin = admin.profile_admin
if profile_admin.nil?
  puts "Creating ProfileAdmin for admin..."
  
  # Create an IndividualEntity for the admin first
  admin_entity = IndividualEntity.create!(
    name: "João",
    last_name: "Silva Advogado",
    cpf: generate_cpf,
    gender: "M",
    profession: "Advogado",
    nationality: "Brasileiro",
    civil_status: "married",
    birth: 35.years.ago
  )
  
  profile_admin = ProfileAdmin.create!(
    admin: admin,
    name: admin_entity.name,
    last_name: admin_entity.last_name,
    cpf: admin_entity.cpf,
    individual_entity_id: admin_entity.id,
    status: "active",
    role: "lawyer",
    civil_status: "married",
    gender: "male",
    nationality: "brazilian",
    oab: "OAB/SP 123456",
    rg: "123456789",
    birth: admin_entity.birth,
    mother_name: "Maria Silva"
  )
end

lawyer_entity = IndividualEntity.find(profile_admin.individual_entity_id) if profile_admin.individual_entity_id
lawyer_entity ||= admin_entity  # fallback to the entity we just created
puts "Using lawyer (admin): #{lawyer_entity.full_name}"

puts "\n" + "-" * 40
puts "Creating 5 Individual Entities with Customers"
puts "-" * 40

5.times do |i|
  # Create IndividualEntity
  individual = IndividualEntity.create!(
    name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    cpf: generate_cpf,
    rg: "#{rand(10000000..99999999)}",
    gender: ["M", "F"].sample,
    nationality: ["Brasileiro", "Portuguesa", "Italiana", "Alemã"].sample,
    civil_status: ["single", "married", "divorced", "widowed"].sample,
    profession: ["Engenheiro", "Médico", "Professor", "Empresário", "Advogado"].sample,
    birth: rand(25..65).years.ago,
    mother_name: Faker::Name.female_first_name + " " + Faker::Name.last_name,
    nit: "#{rand(10000000000..99999999999)}",
    invalid_person: false
  )
  
  # Create Customer with polymorphic association
  customer = Customer.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    profile_type: "IndividualEntity",
    profile_id: individual.id,
    team: team,
    status: "active",
    confirmed_at: Time.current
  )
  
  puts "✓ Created Individual ##{i + 1}: #{individual.full_name} (Customer: #{customer.email})"
end

puts "\n" + "-" * 40
puts "Creating 5 Legal Entities with Customers"
puts "-" * 40

legal_entities = []
5.times do |i|
  # Determine entity type
  entity_types = ["law_firm", "company", "office"]
  entity_type = i < 3 ? "law_firm" : entity_types.sample
  
  # Create LegalEntity
  legal_entity = LegalEntity.create!(
    name: entity_type == "law_firm" ? 
      "#{Faker::Name.last_name} & #{Faker::Name.last_name} Advogados" : 
      Faker::Company.name,
    cnpj: generate_cnpj,
    state_registration: "#{rand(100000000..999999999)}",
    number_of_partners: rand(1..10),
    status: "active",
    accounting_type: ["simples_nacional", "lucro_presumido", "lucro_real"].sample,
    entity_type: entity_type,
    legal_representative: lawyer_entity # Using our admin's individual entity
  )
  
  legal_entities << legal_entity
  
  # Create Customer with polymorphic association
  customer = Customer.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    profile_type: "LegalEntity",
    profile_id: legal_entity.id,
    team: team,
    status: "active",
    confirmed_at: Time.current
  )
  
  puts "✓ Created Legal Entity ##{i + 1}: #{legal_entity.name} (Type: #{entity_type}, Customer: #{customer.email})"
end

puts "\n" + "-" * 40
puts "Creating 5 Legal Entity Offices (Law Firms)"
puts "-" * 40

# Create additional lawyers (IndividualEntities) for partnerships
additional_lawyers = []
3.times do |i|
  lawyer = IndividualEntity.create!(
    name: Faker::Name.first_name,
    last_name: Faker::Name.last_name + " Advogado",
    cpf: generate_cpf,
    rg: "#{rand(10000000..99999999)}",
    gender: ["M", "F"].sample,
    nationality: "Brasileiro",
    civil_status: ["single", "married", "divorced"].sample,
    profession: "Advogado",
    birth: rand(30..55).years.ago,
    mother_name: Faker::Name.female_first_name + " " + Faker::Name.last_name
  )
  additional_lawyers << lawyer
  puts "  Created additional lawyer: #{lawyer.full_name}"
end

# Create LegalEntityOffice for law firms
law_firm_count = 0
legal_entities.each_with_index do |legal_entity, index|
  next unless legal_entity.law_firm? || legal_entity.entity_type == "law_firm"
  
  law_firm_count += 1
  
  # Create LegalEntityOffice
  office = LegalEntityOffice.create!(
    legal_entity: legal_entity,
    oab_id: "OAB/SP #{rand(100000..999999)}",
    inscription_number: "#{rand(1000..9999)}/#{Date.current.year}",
    society_link: "https://oab.org.br/sociedade/#{rand(100000..999999)}",
    legal_specialty: ["Criminal", "Civil", "Trabalhista", "Tributário", "Empresarial"].sample,
    team: team
  )
  
  # Add the main admin as a partner
  office.legal_entity_office_relationships.create!(
    lawyer: lawyer_entity,
    partnership_type: "socio",
    ownership_percentage: 40.0
  )
  
  # Add some additional lawyers as partners/associates
  num_lawyers = rand(1..2)
  num_lawyers.times do |i|
    lawyer = additional_lawyers.sample
    
    relationship = office.legal_entity_office_relationships.create!(
      lawyer: lawyer,
      partnership_type: ["socio", "associado", "socio_de_servico"].sample,
      ownership_percentage: i == 0 ? 30.0 : 15.0
    )
    
    puts "    Added #{lawyer.full_name} as #{relationship.partnership_type} (#{relationship.ownership_percentage}%)"
  end
  
  puts "✓ Created Law Office ##{law_firm_count}: #{legal_entity.name}"
  puts "  OAB ID: #{office.oab_id}"
  puts "  Specialty: #{office.legal_specialty}"
  puts "  Total lawyers: #{office.lawyers.count}"
  puts "  Total ownership: #{office.total_ownership_percentage}%"
end

# Create 2 more offices if we don't have 5 yet
while law_firm_count < 5
  law_firm_count += 1
  
  # Create a new law firm legal entity
  legal_entity = LegalEntity.create!(
    name: "#{Faker::Name.last_name} & Associados Advocacia",
    cnpj: generate_cnpj,
    state_registration: "#{rand(100000000..999999999)}",
    number_of_partners: rand(2..5),
    status: "active",
    accounting_type: "simples_nacional",
    entity_type: "law_firm",
    legal_representative: lawyer_entity
  )
  
  # Create the office
  office = LegalEntityOffice.create!(
    legal_entity: legal_entity,
    oab_id: "OAB/RJ #{rand(100000..999999)}",
    inscription_number: "#{rand(1000..9999)}/#{Date.current.year}",
    society_link: "https://oab.org.br/sociedade/#{rand(100000..999999)}",
    legal_specialty: ["Família", "Imobiliário", "Consumidor", "Previdenciário"].sample,
    team: team
  )
  
  # Add lawyers
  office.legal_entity_office_relationships.create!(
    lawyer: lawyer_entity,
    partnership_type: "socio",
    ownership_percentage: 50.0
  )
  
  if additional_lawyers.any?
    lawyer = additional_lawyers.sample
    office.legal_entity_office_relationships.create!(
      lawyer: lawyer,
      partnership_type: "socio",
      ownership_percentage: 50.0
    )
  end
  
  # Create a customer for this law firm
  customer = Customer.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    profile_type: "LegalEntity",
    profile_id: legal_entity.id,
    team: team,
    status: "active",
    confirmed_at: Time.current
  )
  
  puts "✓ Created Additional Law Office ##{law_firm_count}: #{legal_entity.name}"
  puts "  OAB ID: #{office.oab_id}"
  puts "  Specialty: #{office.legal_specialty}"
  puts "  Customer: #{customer.email}"
end

puts "\n" + "=" * 80
puts "Seed Summary"
puts "=" * 80

puts "Total Customers: #{Customer.where.not(profile_type: nil).count}"
puts "  - With IndividualEntity: #{Customer.where(profile_type: 'IndividualEntity').count}"
puts "  - With LegalEntity: #{Customer.where(profile_type: 'LegalEntity').count}"
puts "\nTotal IndividualEntities: #{IndividualEntity.count}"
puts "Total LegalEntities: #{LegalEntity.count}"
puts "  - Law Firms: #{LegalEntity.where(entity_type: 'law_firm').count}"
puts "  - Companies: #{LegalEntity.where(entity_type: 'company').count}"
puts "  - Offices: #{LegalEntity.where(entity_type: 'office').count}"
puts "\nTotal LegalEntityOffices: #{LegalEntityOffice.count}"
puts "Total Lawyer Relationships: #{LegalEntityOfficeRelationship.count}"
puts "  - Partners (sócios): #{LegalEntityOfficeRelationship.where(partnership_type: 'socio').count}"
puts "  - Associates: #{LegalEntityOfficeRelationship.where(partnership_type: 'associado').count}"
puts "  - Service Partners: #{LegalEntityOfficeRelationship.where(partnership_type: 'socio_de_servico').count}"

puts "\n" + "=" * 80
puts "Polymorphic Customer Seeds Completed!"
puts "=" * 80