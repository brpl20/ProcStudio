# frozen_string_literal: true

# ==========================================
# CUSTOMERS AND PROFILE CUSTOMERS with Polymorphic Associations
# ==========================================
Rails.logger.debug '[CUSTOMERS] Creating Customers and ProfileCustomers with nested attributes...'

# Get references to users and teams from previous seed files
user1 = User.find_by(email: 'u1@gmail.com')
user2 = User.find_by(email: 'u2@gmail.com')
team = Team.find_by(subdomain: 'joao-prado')
team2 = Team.find_by(subdomain: 'terezinha-lawyer')

# Customer 1 - Individual
customer1 = Customer.find_or_create_by!(email: 'cliente1@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
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
      account_type: 'checking',
      agency: '2222',
      account: '333444',
      pix: '123.456.789-09'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.full_name} with nested attributes" }
end

# Customer 2 - Company
customer2 = Customer.find_or_create_by!(email: 'empresa@empresa.com.br') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
end

ProfileCustomer.find_or_create_by!(customer: customer2) do |pc|
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
      account_type: 'checking',
      agency: '1234',
      account: '98765',
      pix: '11.444.777/0001-61'
    },
    {
      bank_name: 'Santander',
      account_type: 'savings',
      agency: '5678',
      account: '55555',
      pix: 'empresa@pix.com.br'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.name} with nested attributes" }
end

# Customer 3 - Individual with representative (minor)
customer3 = Customer.find_or_create_by!(email: 'cliente.menor@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user2.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
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

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.full_name} with nested attributes" }
end

# Customer 4 - Pedro's Mother (Ana Silva)
customer4 = Customer.find_or_create_by!(email: 'ana.silva@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user2.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
end

profile_customer4 = ProfileCustomer.find_or_create_by!(customer: customer4) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Ana'
  pc.last_name = 'Silva'
  pc.cpf = '645.737.937-04' # Valid test CPF
  pc.rg = '1122334'
  pc.birth = Date.parse('1980-03-20')
  pc.gender = 'female'
  pc.civil_status = 'married'
  pc.nationality = 'brazilian'
  pc.profession = 'Professora'
  pc.mother_name = 'Carmen Silva'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user2.id

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
      phone_number: '4533445566'
    }
  ]

  pc.emails_attributes = [
    {
      email: 'ana.silva@gmail.com',
      email_type: 'main'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.full_name} with nested attributes" }
end

# Customer 5 - Another individual
customer5 = Customer.find_or_create_by!(email: 'joao.santos@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user1.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
end

profile_customer5 = ProfileCustomer.find_or_create_by!(customer: customer5) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'João'
  pc.last_name = 'Santos'
  pc.cpf = '842.563.258-75' # Valid test CPF
  pc.rg = '5566778'
  pc.birth = Date.parse('1975-11-10')
  pc.gender = 'male'
  pc.civil_status = 'divorced'
  pc.nationality = 'brazilian'
  pc.profession = 'Contador'
  pc.mother_name = 'Rosa Santos'
  pc.capacity = 'able'
  pc.status = 'active'
  pc.created_by_id = user1.id

  pc.addresses_attributes = [
    {
      zip_code: '85810040',
      street: 'Rua Paraná',
      number: '789',
      complement: 'Casa',
      neighborhood: 'Jardim Coopagro',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  pc.phones_attributes = [
    {
      phone_number: '4588776655'
    }
  ]

  pc.emails_attributes = [
    {
      email: 'joao.santos@gmail.com',
      email_type: 'main'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.full_name} with nested attributes" }
end

# Customer 6 - Elderly person with incapacity
customer6 = Customer.find_or_create_by!(email: 'maria.idosa@gmail.com') do |c|
  c.password = 'ClientPass123!'
  c.password_confirmation = 'ClientPass123!'
  c.confirmed_at = Time.current
  c.created_by_id = user2.id
  Rails.logger.debug { "  [OK] Created customer: #{c.email}" }
end

profile_customer6 = ProfileCustomer.find_or_create_by!(customer: customer6) do |pc|
  pc.customer_type = 'physical_person'
  pc.name = 'Maria'
  pc.last_name = 'Pereira'
  pc.cpf = '261.631.562-93' # Valid test CPF
  pc.rg = '9988776'
  pc.birth = Date.parse('1930-05-15')
  pc.gender = 'female'
  pc.civil_status = 'widower'
  pc.nationality = 'brazilian'
  pc.profession = 'Aposentada'
  pc.mother_name = 'Josefa Pereira'
  pc.capacity = 'unable'
  pc.status = 'active'
  pc.created_by_id = user2.id

  pc.addresses_attributes = [
    {
      zip_code: '85810050',
      street: 'Rua Rio Grande do Sul',
      number: '321',
      complement: 'Casa',
      neighborhood: 'Brazmadeira',
      city: 'Cascavel',
      state: 'PR',
      address_type: 'main'
    }
  ]

  pc.phones_attributes = [
    {
      phone_number: '4522334455'
    }
  ]

  pc.emails_attributes = [
    {
      email: 'maria.pereira@gmail.com',
      email_type: 'main'
    }
  ]

  Rails.logger.debug { "  [OK] Created profile customer: #{pc.full_name} with nested attributes" }
end

# Create multiple representative relationships
# 1. Carlos (father) representing Pedro (minor)
Represent.find_or_create_by!(
  profile_customer: profile_customer3,
  representor: profile_customer1,
  team: team,
  relationship_type: 'representation'
) do |r|
  r.notes = 'Father representing minor son'
  Rails.logger.debug '  [OK] Created representative relationship: Carlos -> Pedro (father)'
end

# 2. Ana (mother) also representing Pedro (minor) - Multiple representors for same client
Represent.find_or_create_by!(
  profile_customer: profile_customer3,
  representor: profile_customer4,
  team: team,
  relationship_type: 'representation'
) do |r|
  r.notes = 'Mother representing minor son'
  Rails.logger.debug '  [OK] Created representative relationship: Ana -> Pedro (mother)'
end

# 3. João representing Maria (elderly incapacitated person)
Represent.find_or_create_by!(
  profile_customer: profile_customer6,
  representor: profile_customer5,
  team: team,
  relationship_type: 'curatorship'
) do |r|
  r.notes = 'Court-appointed curator for elderly person'
  Rails.logger.debug '  [OK] Created representative relationship: João -> Maria (curator)'
end

# 4. Carlos also helping with Maria's representation - Multiple representors for same client
Represent.find_or_create_by!(
  profile_customer: profile_customer6,
  representor: profile_customer1,
  team: team,
  relationship_type: 'assistance'
) do |r|
  r.notes = 'Additional legal assistance for elderly person'
  Rails.logger.debug '  [OK] Created representative relationship: Carlos -> Maria (assistance)'
end

# Associate customers with teams
TeamCustomer.find_or_create_by!(team: team, customer: customer1, customer_email: customer1.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer2, customer_email: customer2.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer3, customer_email: customer3.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer4, customer_email: customer4.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer5, customer_email: customer5.email)
TeamCustomer.find_or_create_by!(team: team, customer: customer6, customer_email: customer6.email)
TeamCustomer.find_or_create_by!(team: team2, customer: customer1, customer_email: customer1.email)

Rails.logger.debug '  [OK] All 6 customers created successfully with polymorphic associations!'
Rails.logger.debug '  [OK] Multiple representation relationships established:'
Rails.logger.debug '      - Pedro (minor): represented by Carlos (father) AND Ana (mother)'
Rails.logger.debug '      - Maria (elderly): represented by João (curator) AND Carlos (assistance)'
