# frozen_string_literal: true

namespace :seed do
  desc 'Seed customers with profiles and contact information'
  task customers: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    puts "🔍 Verificando dependências necessárias..."
    
    # Verificar se existe pelo menos um admin
    if Admin.count.zero?
      puts "❌ ERRO: Nenhum Admin encontrado!"
      puts "   Por favor, execute primeiro: rake cad:admin ou rake seed:admins"
      exit 1
    end

    # Verificar se existe pelo menos um team
    if Team.count.zero?
      puts "❌ ERRO: Nenhum Team encontrado!"
      puts "   Por favor, execute primeiro: rake seed:teams"
      exit 1
    end

    puts "✅ Dependências verificadas com sucesso!"
    puts "📝 Iniciando criação de customers..."

    # Pegar o primeiro admin para ser o criador
    creator = Admin.first
    
    # Criar 10 customers
    10.times do |i|
      ActiveRecord::Base.transaction do
        # Criar o customer
        customer = Customer.create!(
          email: Faker::Internet.unique.email,
          password: '123456',
          password_confirmation: '123456',
          created_by_id: creator.id,
          status: 'active',
          confirmed_at: Time.current # Para evitar necessidade de confirmação
        )

        # Criar o perfil do customer
        profile = ProfileCustomer.create!(
          customer: customer,
          customer_type: ['physical_person', 'company'].sample,
          name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          gender: ['male', 'female'].sample,
          rg: Faker::Number.number(digits: 9).to_s,
          cpf: Faker::Number.number(digits: 11).to_s,
          cnpj: ['physical_person'].include?(customer.profile_customer&.customer_type) ? nil : Faker::Number.number(digits: 14).to_s,
          nationality: ['brazilian', 'foreigner'].sample,
          civil_status: ['single', 'married', 'divorced', 'widowed'].sample,
          capacity: ['able', 'unable'].sample,
          profession: Faker::Job.title,
          company: Faker::Company.name,
          birth: Faker::Date.birthday(min_age: 18, max_age: 65),
          mother_name: Faker::Name.female_first_name + ' ' + Faker::Name.last_name,
          nit: Faker::Alphanumeric.alpha(number: 11),
          inss_password: Faker::Alphanumeric.alphanumeric(number: 8),
          status: [0, 1].sample,
          created_by_id: creator.id
        )

        # Adicionar telefones
        2.times do
          phone = Phone.create!(
            phone_number: Faker::PhoneNumber.cell_phone,
            created_at: Time.current,
            updated_at: Time.current
          )
          CustomerPhone.create!(
            profile_customer: profile,
            phone: phone,
            created_at: Time.current,
            updated_at: Time.current
          )
        end

        # Adicionar emails
        2.times do |j|
          email = Email.create!(
            email: Faker::Internet.unique.email,
            created_at: Time.current,
            updated_at: Time.current
          )
          CustomerEmail.create!(
            profile_customer: profile,
            email: email,
            created_at: Time.current,
            updated_at: Time.current
          )
        end

        # Adicionar endereço
        address = Address.create!(
          description: ['Casa', 'Trabalho', 'Outro'].sample,
          zip_code: Faker::Address.zip_code,
          street: Faker::Address.street_name,
          number: Faker::Address.building_number,
          neighborhood: Faker::Address.community,
          city: Faker::Address.city,
          state: Faker::Address.state_abbr,
          created_at: Time.current,
          updated_at: Time.current
        )
        CustomerAddress.create!(
          profile_customer: profile,
          address: address,
          created_at: Time.current,
          updated_at: Time.current
        )

        # Adicionar conta bancária
        bank_account = BankAccount.create!(
          bank_name: ['Banco do Brasil', 'Bradesco', 'Itaú', 'Caixa', 'Santander'].sample,
          type_account: ['Conta Corrente', 'Conta Poupança'].sample,
          agency: Faker::Number.number(digits: 4).to_s,
          account: Faker::Number.number(digits: 8).to_s,
          operation: Faker::Number.number(digits: 3).to_s,
          pix: [Faker::PhoneNumber.cell_phone, profile.cpf, customer.email].sample,
          created_at: Time.current,
          updated_at: Time.current
        )
        CustomerBankAccount.create!(
          profile_customer: profile,
          bank_account: bank_account,
          created_at: Time.current,
          updated_at: Time.current
        )

        puts "✅ Customer #{i + 1}/10: #{profile.name} #{profile.last_name} (#{customer.email})"
      end
    end

    puts "\n🎉 Seed de customers concluído com sucesso!"
    puts "   Total de customers criados: 10"
    puts "   Total de customers no banco: #{Customer.count}"
  end

  desc 'Remove all seeded customers'
  task remove_customers: :environment do
    puts "🗑️  Removendo customers..."
    
    # Remover relações primeiro
    CustomerWork.destroy_all
    CustomerBankAccount.destroy_all
    CustomerAddress.destroy_all
    CustomerEmail.destroy_all
    CustomerPhone.destroy_all
    
    # Remover perfis
    ProfileCustomer.destroy_all
    
    # Remover customers
    Customer.destroy_all
    
    puts "✅ Todos os customers foram removidos!"
  end
end