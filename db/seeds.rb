Faker::Config.locale = 'pt-BR'

puts "Criando Admin Front..."
admin_front = Admin.find_or_create_by!(
  email: 'adminfront@procstudio.com.br'
) do |admin|
  admin.password = '123456'
  admin.password_confirmation = '123456'
end

puts "Criando ProfileAdmin para Admin Front..."
profile_front = ProfileAdmin.find_or_create_by!(
  admin: admin_front
) do |profile|
  profile.role = 'lawyer'
  profile.name = 'Bruno'
  profile.last_name = 'Pellizzetti'
  profile.gender = 'male'
  profile.oab = '54159/PR'
  profile.rg = '12.345.563-8'
  profile.cpf = Faker::Number.number(digits: 11)
  profile.nationality = 'brazilian'
  profile.civil_status = 'single'
  profile.birth = Date.new(1986, 1, 12)
  profile.mother_name = 'Marta da Silva'
  profile.status = 'active'
  profile.office = Office.last
end

# Criando e associando endereço para Admin Front
address_front = Address.create!(
  description: 'Endereço do Admin Front',
  zip_code: '12345-678',
  street: 'Rua Exemplo Front',
  number: 100,
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: 'SP'
)

AdminAddress.create!(
  address: address_front,
  profile_admin: profile_front
)

puts "Criando Admin API..."
admin_api = Admin.find_or_create_by!(
  email: 'adminapi@procstudio.com.br'
) do |admin|
  admin.password = '123456'
  admin.password_confirmation = '123456'
end

puts "Criando ProfileAdmin para Admin API..."
profile_api = ProfileAdmin.find_or_create_by!(
  admin: admin_api
) do |profile|
  profile.role = 'lawyer'
  profile.name = 'Eduarda'
  profile.last_name = 'Blackter'
  profile.gender = 'female'
  profile.oab = '90185/PR'
  profile.rg = '98.765.432-1'
  profile.cpf = Faker::Number.number(digits: 11)
  profile.nationality = 'brazilian'
  profile.civil_status = 'married'
  profile.birth = Date.new(1992, 1, 12)
  profile.mother_name = 'Joaninha Blackter'
  profile.status = 'active'
  profile.office = Office.last
end

# Criando e associando endereço para Admin API
address_api = Address.create!(
  description: 'Endereço do Admin API',
  zip_code: '87654-321',
  street: 'Rua Exemplo API',
  number: 200,
  neighborhood: 'Bela Vista',
  city: 'São Paulo',
  state: 'SP'
)

AdminAddress.create!(
  address: address_api,
  profile_admin: profile_api
)

puts "Criando ou atualizando o Office..."

office_data = {
  name: 'Teste front-end',
  cnpj: '12.345.678/0001-99',
  oab: '123456',
  society: :company,
  foundation: '2020-01-01',
  site: 'https://www.testefront.com',
  cep: '12345-678',
  street: 'Rua Exemplo',
  number: 100,
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: 'SP',
  office_type_id: 1,
  responsible_lawyer_id: nil,
  accounting_type: :simple,
  deleted_at: nil
}

office = Office.find_or_initialize_by(name: office_data[:name])
office.assign_attributes(office_data)
office.profile_admins = [profile_front]
office.save!

backend_office_data = {
  name: 'Teste Back-end',
  cnpj: '68.628.339/0001-70',
  oab: '654321',
  society: :company,
  foundation: '2020-02-02',
  site: 'https://www.testeback.com',
  cep: '12345-678',
  street: 'Rua Exemplo',
  number: 100,
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: 'SP',
  office_type_id: 1,
  responsible_lawyer_id: nil,
  accounting_type: :simple,
  deleted_at: nil
}

office_backend = Office.find_or_initialize_by(name: backend_office_data[:name])
office_backend.assign_attributes(backend_office_data)
office_backend.profile_admins = [profile_api]
office_backend.save!

puts "Office '#{office.name}' criado ou atualizado com sucesso!"

puts "Criando Clientes e seus Perfis..."
3.times do |i|
  puts "Criando cliente #{i+1}..."
  customer = Customer.create!(
    email: Faker::Internet.unique.email(domain: 'procstudio.com.br'),
    password: '123456',
    password_confirmation: '123456',
  )

  address = Address.create!(
    street: Faker::Address.street_name,
    number: Faker::Address.building_number,
    neighborhood: Faker::Address.community,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.postcode
  )

  puts "Criando perfil para cliente #{i+1}..."
  profile = ProfileCustomer.create!(
    customer_type: ['physical_person', 'legal_person', 'representative', 'counter'].sample,
    name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    gender: ['male', 'female', 'other'].sample,
    rg: "#{rand(10..99)}.#{rand(100..999)}.#{rand(100..999)}-#{rand(1..9)}",
    cpf: Faker::Number.number(digits: 11),
    cnpj: Faker::Number.number(digits: 14),
    nationality: 'brazilian',
    civil_status: ['single', 'married', 'divorced', 'widower', 'union'].sample,
    capacity: 'able',
    profession: Faker::Company.profession,
    company: Faker::Company.name,
    birth: Faker::Date.between(from: 65.years.ago, to: 18.years.ago),
    mother_name: Faker::Name.female_first_name + " " + Faker::Name.last_name,
    number_benefit: rand.to_s[2..11],
    status: 'active',
    nit: rand.to_s[2..11],
    inss_password: rand.to_s[2..7],
    invalid_person: [0, 1].sample,
    customer: customer,
  )

  CustomerAddress.create!(
    profile_customer: profile,
    address: address
  )

  puts "Cliente #{i+1} criado com sucesso!"
end

puts "Criando ou atualizando Powers..."

powers = [
  { description: 'Permite gerenciar usuários e configurações do sistema', category: :admgeneral },
  { description: 'Acesso ao módulo financeiro para controle de pagamentos', category: :admspecific },
  { description: 'Permite a geração e visualização de relatórios gerenciais', category: :lawspecific },
  { description: 'Acesso ao módulo de atendimento ao cliente', category: :lawgeneral },
  { description: 'Permite acessar processos jurídicos e documentos legais', category: :lawspecificsecret }
]

powers.each do |power_data|
  power = Power.find_or_initialize_by(description: power_data[:description])
  power.category = power_data[:category]
  power.save!
  puts "Power com descrição '#{power.description}' criado ou atualizado com sucesso!"
end

puts "Powers criados/atualizados com sucesso!"

puts "Dados de Seed finalizados com sucesso!"
