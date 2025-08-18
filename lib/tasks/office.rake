# frozen_string_literal: true

require 'bundler/setup'
require 'faker'

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task office: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    Office.create!(
      name: 'João Augusto Prado Sociedade Unipessoal de Advocacia',
      cnpj: '49.609.519/0001-60',
      oab: '15.074 PR',
      society: 'society', # Se for sociedade simples, está correto
      foundation: '25-09-2023',
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
          bank_name: 'Sicredi',
          type_account: 'Pagamentos',
          agency: '0710',
          account: '5445109',
          operation: '0',
          pix: '49609519000160'
        }
      ],
      phones_attributes: [
        {
          phone_number: '45 3038-5898'
        }
      ],
      emails_attributes: [
        {
          email: 'joao@pellizzetti.adv.br'
        }
      ]
    )
  end
end
