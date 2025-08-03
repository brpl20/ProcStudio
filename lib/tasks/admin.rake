namespace :cad do
  desc 'Criação dos admins para serem utilizadores do sistema'
  task admin: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    admin_only = ENV['ADMIN_ONLY'] == 'true'

    # 1. Create Bruno Admin
    bruno_admin = Admin.create!(
      email: 'bruno@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    # 2. Create Eduardo Admin (lawyer)
    eduardo_admin = Admin.create!(
      email: 'eduardo@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    # 3. Create João Admin (lawyer)
    joao_admin = Admin.create!(
      email: 'joao@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    # 4. Create Valdirene Admin (secretary)
    valdirene_admin = Admin.create!(
      email: 'valdirene@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    # Create ProfileAdmin only if admin_only flag is not passed
    unless admin_only
      # Create Bruno's profile
      bruno_profile = ProfileAdmin.create!(
        role: 'lawyer',
        status: 'active',
        name: 'Bruno',
        last_name: 'Pellizzetti',
        gender: 'male',
        oab: '54.159 PR',
        rg: '7.059.987-2 SSP/PR',
        cpf: '058.802.539-96',
        nationality: 'brazilian',
        civil_status: 'single',
        birth: '01-01-1986',
        mother_name: 'Ivete Goinski Pellizzetti',
        admin: bruno_admin,
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
        phones_attributes: [
          {
            phone_number: "45 98405-5504"
          }
        ],
        emails_attributes: [
          {
            email: "bruno@pellizzetti.adv.br"
          }
        ]
      )

      # Create Eduardo's profile
      eduardo_profile = ProfileAdmin.create!(
        role: 'lawyer',
        status: 'active',
        name: 'Eduardo',
        last_name: 'Walber',
        gender: 'male',
        oab: '106.344 PR',
        rg: '12705740-0 SESP PR',
        cpf: '063.989.629-40',
        nationality: 'brazilian',
        civil_status: 'single',
        birth: '13-03-1998',
        mother_name: 'Cleide Bertolin Walber',
        admin: eduardo_admin,
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
        phones_attributes: [
          {
            phone_number: "45 9845-2869"
          }
        ],
        emails_attributes: [
          {
            email: "eduardo@pellizzetti.adv.br"
          }
        ]
      )

      # Create João's profile
      joao_profile = ProfileAdmin.create!(
        role: 'lawyer',
        status: 'active',
        name: 'João Augusto',
        last_name: 'Prado',
        gender: 'male',
        oab: '110.025 PR',
        rg: '998979601 SESP PR',
        cpf: '080.391.959-00',
        nationality: 'brazilian',
        civil_status: 'single',
        birth: '16-10-1991',
        mother_name: 'Rosinha Mendes Prado',
        admin: joao_admin,
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
        emails_attributes: [
          {
            email: "joao@pellizzetti.adv.br"
          }
        ]
      )

      # Create Valdirene's profile (secretary)
      valdirene_profile = ProfileAdmin.create!(
        role: 'secretary',
        status: 'active',
        name: 'Valdirene',
        last_name: 'Santos',
        gender: 'female',
        rg: '73711754',
        cpf: '02994736942',
        nationality: 'brazilian',
        civil_status: 'single',
        birth: '26-02-1977',
        mother_name: 'Constancia dos Santos',
        admin: valdirene_admin,
        addresses_attributes: [
          {
            zip_code: '85816-060',
            number: '188',
            street: 'Rua Castro',
            neighborhood: "São Cristoval",
            city: "Cascavel",
            state: "PR"
          }
        ],
        emails_attributes: [
          {
            email: "valdirene@pellizzetti.adv.br"
          }
        ]
      )
    end
  end
end
