# frozen_string_literal: true
require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

puts "Starting seed process..."

# First: Create/Update Office Types
puts "Creating/Updating Office Types..."
types = %w[Advocacia Consultoria Contabilidade]
types.each do |t|
  OfficeType.find_or_create_by(description: t.to_s) do |office_type|
    puts "Created office type: #{office_type.description}"
  end
end
puts "Office types processed successfully!"


# Second: Create Office
puts "Creating Office..."
office = Office.create!(
  name: 'João Augusto Prado Sociedade Unipessoal de Advocacia',
  cnpj: '49.609.519/0001-60',
  oab: '15.074 PR',
  society: 'individual',
  foundation: Date.parse('25-09-2023'),
  site: 'pellizzetti.adv.br',
  zip_code: '85810-010',
  street: 'Rua Paraná',
  number: '3033',
  neighborhood: 'Centro',
  city: 'Cascavel',
  state: 'PR',
  office_type_id: 1,
  bank_accounts_attributes: [
    {
      bank_name: "Sicredi",
      type_account: "Pagamentos",
      agency: "0710",
      account: "5445109",
      operation: "0",
      pix: "49609519000160"
    }
  ],
  phones_attributes: [
    {
      phone_number: "45 3038-5898"
    }
  ]
)
puts "Office created successfully: #{office.name}"

# Third: Create Admin and ProfileAdmin
puts "Creating Admin and ProfileAdmin..."
admin = Admin.create!(
  email: 'joao@pellizzetti.adv.br',
  password: 'Galego123',
  password_confirmation: 'Galego123'
)

profile = ProfileAdmin.create!(
  role: 'lawyer',
  status: 'active',
  name: 'João Augusto',
  last_name: 'Prado',
  gender: 'male',
  oab: '110.025 PR',
  rg: '998979601 SESP PR',
  cpf: '080.391.959-00',
  nationality: 'brazilian',
  civil_status: 'married',
  birth: Date.parse('16-10-1991'),
  mother_name: 'Rosinha Mendes Prado',
  admin: admin,
  office: office,
  addresses_attributes: [
    {
      description: '14 Andar',
      zip_code: '85810-010',
      number: '3033',
      street: 'Rua Paraná',
      neighborhood: "Centro",
      city: "Cascavel",
      state: "PR"
    }
  ],
  bank_accounts_attributes: [
    {
      bank_name: "Nu Pagamentos",
      type_account: "Pagamentos",
      agency: "000-1",
      account: "40249656-0",
      operation: "0",
      pix: "08039195900"
    }
  ],
  phones_attributes: [
    {
      phone_number: "45 9853-4569"
    }
  ],
  emails_attributes: [
    {
      email: "joao@pellizzetti.adv.br"
    }
  ]
)

puts "Admin and ProfileAdmin created successfully: #{profile.name} #{profile.last_name}"
puts "Seed process completed!"
