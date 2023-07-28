# frozen_string_literal: true

class PendingDocument < ApplicationRecord
  belongs_to :work

  enum description: {
    rg: 'Documento de identidade',
    proof_of_address: 'Comprovante de residência',
    inss_password: 'Senha do meu Inss',
    medical_documents: 'Documentos Médicos',
    rural_documents: 'Documentos Rurais',
    copy_of_requirements: 'Cópia de requerimentos'
  }
end
