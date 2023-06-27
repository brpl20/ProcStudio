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
  end
end
