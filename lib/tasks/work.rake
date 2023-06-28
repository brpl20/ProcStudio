# frozen_string_literal: true

namespace :cad do
  desc 'Criação dos offices_types para serem utilizados nos escritórios'
  task work: :environment do
    checklists = ['Procuração', 'Termo de Renúncia', 'Declaração de Carência', 'Termo de Residência', 'Declaração Rural']

    checklists.each do |t|
      Checklist.find_or_create_by(
        description: t.to_s
      )
    end

    checklist_documents = ['Documento de Identidade', 'Comprovante de Residência', 'Senha do Meu INSS', 'Documentos Médicos', 'Documentos Rurais', 'Cópia de Requerimento(s)']

    checklist_documents.each do |t|
      ChecklistDocument.find_or_create_by(
        description: t.to_s
      )
    end

    10.times do
      Work.create(
        procedure: 'administrativo',
        subject: 'civel',
        action: 'familia',
        number: Faker::Number.number(digits: 4),
        rate_percentage: Faker::Number.decimal(l_digits: 2),
        rate_percentage_exfield: Faker::Number.decimal(l_digits: 2),
        rate_fixed: Faker::Number.decimal(l_digits: 2),
        rate_parceled_exfield: Faker::Number.decimal(l_digits: 2),
        folder: Faker::Lorem.word,
        initial_atendee: Faker::Name.name,
        note: Faker::Lorem.paragraph,
        checklist: Checklist.last,
        pending_document: ''
      )
    end
  end
end
