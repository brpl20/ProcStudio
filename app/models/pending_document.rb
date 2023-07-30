# frozen_string_literal: true

class PendingDocument < ApplicationRecord
  belongs_to :work

  enum description: {
    rg: 'documento_identidade',
    proof_of_address: 'comprovante_residência',
    inss_password: 'senha_inss',
    medical_documents: 'documentos_medicos',
    rural_documents: 'documentos_rurais',
    copy_of_requirements: 'copia_requerimentos'
  }
end
