# frozen_string_literal: true

require 'bundler/setup'
require 'faker'

namespace :cad do
  desc 'Criação dos admins para serem utilizadores do sistema'
  task admin: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    Admin.create!(
      email: 'bruno@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    ProfileAdmin.create!(
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
      admin: Admin.last,
      addresses_attributes: [
        {
          description: '14 Andar',
          zip_code: '85810-010',
          number: '3033',
          street: 'Rua Paraná',
          neighborhood: 'Centro',
          city: 'Cascavel',
          state: 'PR'
        }
      ],
      bank_accounts_attributes: [
        {
          bank_name: 'Nu Pagamentos',
          type_account: 'Pagamentos',
          agency: '000-1',
          account: '40249656-0',
          operation: '0',
          pix: '05880253996'
        }
      ],
      phones_attributes: [
        {
          phone_number: '45 98405-5504'
        }
      ],
      emails_attributes: [
        {
          email: 'bruno@pellizzetti.adv.br'
        }
      ]
    )

    Admin.create!(
      email: 'eduardo@pellizzetti.adv.br',
      password: 'Galego123',
      password_confirmation: 'Galego123'
    )

    ProfileAdmin.create!(
      role: 'lawyer',
      status: 'active',
      name: 'Eduardo',
      last_name: 'Walber',
      gender: 'male',
      oab: '106.344 PR',
      rg: '12705740-0 SESP PR',
      cpf: '063.989.629-40',
      nationality: 'brazilian',
      civil_status: 'married',
      birth: '13-03-1998',
      mother_name: 'Cleide Bertolin Walber',
      admin: Admin.last,
      addresses_attributes: [
        {
          description: '14 Andar',
          zip_code: '85810-010',
          number: '3033',
          street: 'Rua Paraná',
          neighborhood: 'Centro',
          city: 'Cascavel',
          state: 'PR'
        }
      ],
      bank_accounts_attributes: [
        {
          bank_name: 'Nu Pagamentos',
          type_account: 'Pagamentos',
          agency: '000-1',
          account: '40249656-0',
          operation: '0',
          pix: '05880253996'
        }
      ],
      phones_attributes: [
        {
          phone_number: '45 9845-2869'
        }
      ],
      emails_attributes: [
        {
          email: 'eduardo@pellizzetti.adv.br'
        }
      ]
    )
  end
end
