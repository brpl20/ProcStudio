# frozen_string_literal: true

class Document < ApplicationRecord
  belongs_to :work
  has_one_attached :document_docx

  enum document_type: {
    procuration: 'procuration', # procuracao
    waiver: 'waiver', # termo de renuncia
    deficiency_statement: 'deficiency statement' # declaracao de carencia
  }

  scope :procurations, -> { where(document_type: 'procuration') }
end
