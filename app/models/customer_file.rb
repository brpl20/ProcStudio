# frozen_string_literal: true

class CustomerFile < ApplicationRecord
  belongs_to :profile_customer
  has_one_attached :document_docx

  enum file_description: {
    simple_procuration: 'simple procuration', # procuracao simples
    rg: 'rg',
    cpf: 'cpf',
    proof_of_address: 'proof of address' # comprovante de endereco
  }

  scope :simple_procuration, -> { where(file_description: 'simple_procuration') }
end
