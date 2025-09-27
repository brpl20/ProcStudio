# frozen_string_literal: true

# ==========================================
# CUSTOMERS AND PROFILE CUSTOMERS with Polymorphic Associations
# ==========================================
puts '[CUSTOMERS] Creating Customers and ProfileCustomers with nested attributes...'

# Get references to users and teams from previous seed files
user1 = User.find_by(email: 'joao.prado@advocacia.com.br')
user2 = User.find_by(email: 'maria.silva@advocacia.com.br')
team = Team.find_by(subdomain: 'principal')
team2 = Team.find_by(subdomain: 'filial')

# Customer 1 - Individual
customer1 = Customer.find_or_create_by!(email: 'cliente1@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  puts "  [OK] Created customer: #{c.email}"
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
  
  # Using nested attributes for polymorphic associations
  pc.addresses_attributes = [
    {
      zip_code: '85810020',
      street: 'Rua Brasil',
      number: '100',
      complement: 'Casa',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]
  
  pc.phones_attributes = [
    {
      phone_number: '4598765432'
    },
    {
      phone_number: '45999887766'
    }
  ]
  
  pc.emails_attributes = [
    {
      email: 'carlos.oliveira@gmail.com',
      email_type: 'main'
    }
  ]
  
  pc.bank_accounts_attributes = [
    {
      bank_name: 'Caixa Econômica Federal',
      type_account: 'checking',
      agency: '2222',
      account: '333444',
      pix: '123.456.789-09',
      account_type: 'main'
    }
  ]
  
  puts "  [OK] Created profile customer: #{pc.full_name} with nested attributes"
end

# Customer 2 - Company
customer2 = Customer.find_or_create_by!(email: 'empresa@empresa.com.br') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  puts "  [OK] Created customer: #{c.email}"
end

profile_customer2 = ProfileCustomer.find_or_create_by!(customer: customer2) do |pc|
  pc.customer_type = 'legal_person'
  pc.name = 'Empresa Exemplo LTDA'
  pc.cnpj = '11.444.777/0001-61' # Valid test CNPJ
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
  
  # Using nested attributes for polymorphic associations
  pc.addresses_attributes = [
    {
      zip_code: '01310200',
      street: 'Avenida Paulista',
      number: '2000',
      complement: 'Andar 10, Sala 1001',
      neighborhood: 'Bela Vista',
      city: 'São Paulo',
      state: 'SP',
      address_type: 'main'
    },
    {
      zip_code: '01310300',
      street: 'Rua Haddock Lobo',
      number: '595',
      complement: 'Depósito',
      neighborhood: 'Cerqueira César',
      city: 'São Paulo',
      state: 'SP',
      address_type: 'secondary'
    }
  ]
  
  pc.phones_attributes = [
    {
      phone_number: '1133445566'
    },
    {
      phone_number: '11955443322'
    }
  ]
  
  pc.emails_attributes = [
    {
      email: 'contato@empresa.com.br',
      email_type: 'main'
    },
    {
      email: 'financeiro@empresa.com.br',
      email_type: 'secondary'
    },
    {
      email: 'juridico@empresa.com.br',
      email_type: 'work'
    }
  ]
  
  pc.bank_accounts_attributes = [
    {
      bank_name: 'Banco do Brasil',
      type_account: 'checking',
      agency: '1234',
      account: '98765',
      pix: '11.444.777/0001-61',
      account_type: 'main'
    },
    {
      bank_name: 'Santander',
      type_account: 'savings_account',
      agency: '5678',
      account: '55555',
      pix: 'empresa@pix.com.br',
      account_type: 'savings'
    }
  ]
  
  puts "  [OK] Created profile customer: #{pc.name} with nested attributes"
end

# Customer 3 - Individual with representative (minor)
customer3 = Customer.find_or_create_by!(email: 'cliente.menor@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user2.id
  puts "  [OK] Created customer: #{c.email}"
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
  
  # Using nested attributes for polymorphic associations
  pc.addresses_attributes = [
    {
      zip_code: '85810030',
      street: 'Rua São Paulo',
      number: '456',
      complement: 'Apto 202',
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]
  
  pc.phones_attributes = [
    {
      phone_number: '4533221100'
    }
  ]
  
  pc.emails_attributes = [
    {
      email: 'pedro.junior@gmail.com',
      email_type: 'personal'
    }
  ]
  
  puts "  [OK] Created profile customer: #{pc.full_name} with nested attributes"
end

# Create representative for minor
Represent.find_or_create_by!(
  profile_customer: profile_customer3,
  representor: profile_customer1,
  team: team
) do |_r|
  puts '  [OK] Created representative relationship'
end

# Associate customers with teams
TeamCustomer.find_or_create_by!(team: team, customer: customer1, customer_email: customer1.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer2, customer_email: customer2.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer3, customer_email: customer3.email)
TeamCustomer.find_or_create_by!(team: team2, customer: customer1, customer_email: customer1.email)

puts "  [OK] Customers created successfully with polymorphic associations!"