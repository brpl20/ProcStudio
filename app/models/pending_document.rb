# frozen_string_literal: true

# == Schema Information
#
# Table name: pending_documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  description         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint
#  work_id             :bigint           not null
#
# Indexes
#
#  index_pending_documents_on_deleted_at           (deleted_at)
#  index_pending_documents_on_profile_customer_id  (profile_customer_id)
#  index_pending_documents_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#

class PendingDocument < ApplicationRecord
  acts_as_paranoid

  belongs_to :work
  belongs_to :profile_customer

  enum :description, {
    rg: 'documento_identidade',
    proof_of_address: 'comprovante_residência',
    inss_password: 'senha_inss',
    medical_documents: 'documentos_medicos',
    rural_documents: 'documentos_rurais',
    copy_of_requirements: 'copia_requerimentos'
  }
end
