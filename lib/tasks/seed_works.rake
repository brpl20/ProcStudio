# frozen_string_literal: true

namespace :seed do
  desc 'Seed works with all relationships'
  task works: :environment do
    require 'faker'
    Faker::Config.locale = 'pt-BR'

    puts "🔍 Verificando dependências necessárias..."
    
    # Verificar se existe pelo menos um admin
    if Admin.count.zero?
      puts "❌ ERRO: Nenhum Admin encontrado!"
      puts "   Por favor, execute primeiro: rake cad:admin ou rake seed:admins"
      puts "   Admins são necessários para criar Works (advogados responsáveis)"
      exit 1
    end

    # Verificar se existe pelo menos um customer
    if Customer.count.zero?
      puts "❌ ERRO: Nenhum Customer encontrado!"
      puts "   Por favor, execute primeiro: rake seed:customers"
      puts "   Customers são necessários para vincular aos Works (clientes dos processos)"
      exit 1
    end

    # Verificar se existe pelo menos um office
    if Office.count.zero?
      puts "❌ ERRO: Nenhum Office encontrado!"
      puts "   Por favor, execute primeiro: rake cad:office ou rake seed:offices"
      puts "   Offices são necessários para vincular aos Works (escritórios responsáveis)"
      exit 1
    end

    # Verificar se existe pelo menos um team
    if Team.count.zero?
      puts "❌ ERRO: Nenhum Team encontrado!"
      puts "   Por favor, execute primeiro: rake seed:teams"
      puts "   Teams são necessários para organização dos Works"
      exit 1
    end

    # Verificar se existem profile_admins (advogados)
    if ProfileAdmin.count.zero?
      puts "❌ ERRO: Nenhum ProfileAdmin encontrado!"
      puts "   Por favor, certifique-se de que os Admins tenham perfis criados"
      exit 1
    end

    # Verificar se existem profile_customers
    if ProfileCustomer.count.zero?
      puts "❌ ERRO: Nenhum ProfileCustomer encontrado!"
      puts "   Por favor, certifique-se de que os Customers tenham perfis criados"
      exit 1
    end

    puts "✅ Dependências verificadas com sucesso!"
    puts "📝 Iniciando criação de works..."

    # Pegar dados necessários
    creator = Admin.first
    offices = Office.all.to_a
    profile_admins = ProfileAdmin.all.to_a
    profile_customers = ProfileCustomer.all.to_a

    # Criar 15 works
    15.times do |i|
      ActiveRecord::Base.transaction do
        # Selecionar advogados aleatórios (podem ser os mesmos ou diferentes)
        physical_lawyer = profile_admins.sample
        responsible_lawyer = profile_admins.sample
        partner_lawyer = profile_admins.sample

        # Criar o work
        work = Work.create!(
          procedure: Work.procedures.keys.sample,
          subject: Work.subjects.keys.sample,
          number: Faker::Number.number(digits: 7),
          folder: "PASTA-#{Faker::Number.number(digits: 5)}",
          note: Faker::Lorem.paragraph(sentence_count: 3),
          status: Work.statuses.keys.sample,
          created_by_id: creator.id,
          physical_lawyer: physical_lawyer&.id,
          responsible_lawyer: responsible_lawyer&.id,
          partner_lawyer: partner_lawyer&.id,
          lawsuit: [true, false].sample,
          gain_projection: ["Alta", "Média", "Baixa", "Incerta"].sample,
          created_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
          updated_at: Time.current
        )

        # Adicionar área específica baseada no subject
        case work.subject
        when 'civil'
          work.update!(civel_area: Work.civel_areas.keys.sample)
        when 'social_security'
          work.update!(social_security_areas: Work.social_security_areas.keys.sample)
        when 'laborite'
          work.update!(laborite_areas: Work.laborite_areas.keys.sample)
        when 'tributary', 'tributary_pis'
          work.update!(tributary_areas: Work.tributary_areas.keys.sample)
        when 'others'
          work.update!(other_description: Faker::Lorem.paragraph(sentence_count: 2))
        end

        # Vincular clientes ao work (1 a 3 clientes)
        selected_customers = profile_customers.sample(rand(1..3))
        selected_customers.each do |profile_customer|
          CustomerWork.create!(
            profile_customer: profile_customer,
            work: work,
            created_at: work.created_at,
            updated_at: Time.current
          )
        end

        # Vincular advogados ao work
        selected_admins = profile_admins.sample(rand(1..3))
        selected_admins.each do |profile_admin|
          ProfileAdminWork.create!(
            profile_admin: profile_admin,
            work: work,
            created_at: work.created_at,
            updated_at: Time.current
          )
        end

        # Vincular office ao work
        selected_office = offices.sample
        OfficeWork.create!(
          office: selected_office,
          work: work,
          created_at: work.created_at,
          updated_at: Time.current
        )

        # Criar honorário para o work
        Honorary.create!(
          work: work,
          percentage: rand(20..40),
          value: Faker::Number.decimal(l_digits: 4, r_digits: 2),
          description: "Honorários advocatícios - #{work.subject}",
          payment_type: ['percentage', 'fixed', 'mixed'].sample,
          created_at: work.created_at,
          updated_at: Time.current
        )

        # Criar alguns documentos pendentes
        rand(0..3).times do
          PendingDocument.create!(
            work: work,
            name: ["RG", "CPF", "Comprovante de Residência", "Procuração", "Contrato Social", "CNPJ"].sample,
            description: Faker::Lorem.sentence,
            status: ['pending', 'received', 'validated'].sample,
            created_at: work.created_at,
            updated_at: Time.current
          )
        end

        # Criar alguns eventos do work
        rand(2..5).times do |j|
          WorkEvent.create!(
            work: work,
            event_type: ['hearing', 'deadline', 'meeting', 'filing', 'decision'].sample,
            title: ["Audiência", "Prazo processual", "Reunião com cliente", "Protocolo de petição", "Decisão judicial"].sample,
            description: Faker::Lorem.paragraph(sentence_count: 2),
            event_date: Faker::Date.between(from: work.created_at, to: 6.months.from_now),
            status: ['scheduled', 'completed', 'cancelled'].sample,
            created_at: work.created_at,
            updated_at: Time.current
          )
        end

        # Criar algumas recomendações
        rand(0..2).times do
          Recommendation.create!(
            work: work,
            title: ["Juntar documentos", "Agendar perícia", "Solicitar alvará", "Interpor recurso"].sample,
            description: Faker::Lorem.paragraph(sentence_count: 2),
            priority: ['low', 'medium', 'high'].sample,
            status: ['pending', 'in_progress', 'completed'].sample,
            created_at: work.created_at,
            updated_at: Time.current
          )
        end

        puts "✅ Work #{i + 1}/15: #{work.procedure} - #{work.subject} (Processo: #{work.number})"
      end
    end

    puts "\n🎉 Seed de works concluído com sucesso!"
    puts "   Total de works criados: 15"
    puts "   Total de works no banco: #{Work.count}"
    puts "   Total de customer_works: #{CustomerWork.count}"
    puts "   Total de profile_admin_works: #{ProfileAdminWork.count}"
    puts "   Total de office_works: #{OfficeWork.count}"
    puts "   Total de honorários: #{Honorary.count}"
    puts "   Total de documentos pendentes: #{PendingDocument.count}"
    puts "   Total de eventos: #{WorkEvent.count}"
    puts "   Total de recomendações: #{Recommendation.count}"
  end

  desc 'Remove all seeded works and related data'
  task remove_works: :environment do
    puts "🗑️  Removendo works e dados relacionados..."
    
    # Remover relações e dados dependentes primeiro
    WorkEvent.destroy_all
    Recommendation.destroy_all
    PendingDocument.destroy_all
    Document.destroy_all
    Honorary.destroy_all
    Job.destroy_all
    PowerWork.destroy_all
    OfficeWork.destroy_all
    ProfileAdminWork.destroy_all
    CustomerWork.destroy_all
    
    # Remover works
    Work.destroy_all
    
    puts "✅ Todos os works e dados relacionados foram removidos!"
  end
end