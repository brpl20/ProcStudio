# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                  :bigint(8)        not null, primary key
#  document_type       :string
#  work_id             :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint(8)
#  deleted_at          :datetime
#  format              :integer          default("docx"), not null
#  status              :integer          default("pending_review"), not null
#  sign_source         :integer          default("no_signature"), not null
#  team_id             :bigint(8)
#
class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :work

  has_one_attached :file # esse vai ser removido

  has_one_attached :original
  has_one_attached :signed

  validate :sign_source_restriction

  enum document_type: {
    procuration: 'procuration',
    waiver: 'waiver',
    deficiency_statement: 'deficiency statement',
    honorary: 'honorary'
  }

  enum format: [:docx, :pdf]

  enum status: [:pending_review, :approved, :pending_external_signature, :signed]

  enum sign_source: [:no_signature, :manual_signature, :zapsign]

  scope :procurations, -> { where(document_type: 'procuration') }

  def mark_as_pdf_and_approved
    update(format: :pdf, status: :approved)
  end

  def document_name
    case document_type
    when 'procuration'
      'Procuração'
    when 'waiver'
      'Termo de Renúncia'
    when 'deficiency_statement'
      'Declaração de Carência'
    when 'honorary'
      'Contrato de Honorário'
    else
      'Tipo Desconhecido'
    end
  end

  def document_name_parsed
    document_name.to_s
                 .unicode_normalize(:nfkd)
                 .gsub(/[^\x00-\x7F]/, '')
                 .gsub(/[^a-zA-Z0-9\s]/, '')
                 .gsub(/\s+/, '_')
                 .downcase
  end

  private

  def sign_source_restriction
    return unless will_save_change_to_sign_source?

    if status.to_sym == :signed
      errors.add(:sign_source, 'deve ser "manual_signature" ou "zapsign" quando o status for "signed"') unless sign_source.in?(%w[manual_signature zapsign])
    else
      errors.add(:sign_source, 'deve ser "no_signature" quando o status não for "signed"') unless sign_source == 'no_signature'
    end
  end
end
