namespace :cad do
  desc 'Criação dos escritórios e vinculação com admins'
  task office_with_admin: :environment do
    # Create Pellizzetti e Walber office
    pellizzetti_walber_office = Office.create!(
      name: 'Pellizzetti e Walber Advogados Associados',
      cnpj: '49780032000146',  # Removed formatting to match example
      society: 'company',
      foundation: '25-09-2023',
      site: 'pellizzetti.adv.br',
      cep: '85810-010',         # Changed from zip_code to cep
      street: 'Rua Paraná',
      number: 3033,             # Changed to integer instead of string
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      office_type_id: 1,
      accounting_type: 'simple',
      phones_attributes: [
        {
          phone_number: "45 3038-5898"
        }
      ],
      emails_attributes: [
        {
          email: "contato@pellizzetti.adv.br"
        }
      ]
      # Removed bank_accounts_attributes as requested
    )

    # Create João Augusto Prado office
    joao_office = Office.create!(
      name: 'João Augusto Prado Sociedade Unipessoal de Advocacia',
      cnpj: '49609519000160',  # Removed formatting
      oab: '15.074 PR',
      society: 'company',
      foundation: '25-09-2023',
      site: 'pellizzetti.adv.br',
      cep: '85810-010',        # Changed from zip_code to cep
      street: 'Rua Paraná',
      number: 3033,            # Changed to integer
      neighborhood: 'Centro',
      city: 'Cascavel',
      state: 'PR',
      office_type_id: 1,
      accounting_type: 'simple',
      phones_attributes: [
        {
          phone_number: "45 3038-5898"
        }
      ],
      emails_attributes: [
        {
          email: "joao@pellizzetti.adv.br"
        }
      ]
      # Bank details removed as requested
    )

    # Get admin records to link with offices
    bruno_admin = Admin.find_by(email: 'bruno@pellizzetti.adv.br')
    eduardo_admin = Admin.find_by(email: 'eduardo@pellizzetti.adv.br')
    joao_admin = Admin.find_by(email: 'joao@pellizzetti.adv.br')

    # Find ProfileAdmins
    bruno_profile = ProfileAdmin.find_by(admin_id: bruno_admin.id) if bruno_admin
    eduardo_profile = ProfileAdmin.find_by(admin_id: eduardo_admin.id) if eduardo_admin
    joao_profile = ProfileAdmin.find_by(admin_id: joao_admin.id) if joao_admin

    # Set responsible lawyer for offices
    pellizzetti_walber_office.update(responsible_lawyer_id: bruno_profile.id) if bruno_profile
    joao_office.update(responsible_lawyer_id: joao_profile.id) if joao_profile

    # Link Bruno and Eduardo to Pellizzetti e Walber office
    bruno_profile.update(office_id: pellizzetti_walber_office.id) if bruno_profile
    eduardo_profile.update(office_id: pellizzetti_walber_office.id) if eduardo_profile

    # Link João to his own office
    joao_profile.update(office_id: joao_office.id) if joao_profile

  end
end
