# frozen_string_literal: true

namespace :cad do
  desc 'Criação de Profile Customer'
  task customer: :environment do
    customer = Customer.create(
      email: 'admin@admin.com.br',
      password: '123456',
      password_confirmation: '123456'
    )

    Person.find_or_create_by(
      name: 'João',
      lastname: 'Silva',
      gender: 0,
      rg: '123456',
      cpf: '12345678900',
      cnpj: '',
      nationality: 0,
      civil_status: 0,
      capacity: 0,
      profession: 'Estudante',
      company: '',
      birth: '2023-01-01',
      mother_name: 'Joaquina Silva',
      number_benefit: '',
      status: 0,
      document: nil,
      nit: '123456789',
      inss_password: 'Lorem',
      customer_id: customer.id
    )
  end
end
