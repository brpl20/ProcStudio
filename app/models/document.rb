# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id            :bigint(8)        not null, primary key
#  document_type :string
#  work_id       :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
