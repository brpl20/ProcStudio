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
