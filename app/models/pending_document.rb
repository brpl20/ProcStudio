# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_documents
#
#  id          :bigint(8)        not null, primary key
#  description :string
#  work_id     :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
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
