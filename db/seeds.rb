Faker::Config.locale = 'pt-BR'

puts "Criando Admin Front..."
admin_front = Admin.find_or_create_by!(
  email: 'adminfront@procstudio.com.br'
) do |admin|
  admin.password = '123456'
  admin.password_confirmation = '123456'
end

puts "Criando ProfileAdmin para Admin Front..."
ProfileAdmin.find_or_create_by!(
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

puts "Criando Admin API..."
admin_api = Admin.find_or_create_by!(
  email: 'adminapi@procstudio.com.br'
) do |admin|
  admin.password = '123456'
  admin.password_confirmation = '123456'
end

puts "Criando ProfileAdmin para Admin API..."
ProfileAdmin.find_or_create_by!(
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

puts "Dados de Seed finalizados com sucesso!"
