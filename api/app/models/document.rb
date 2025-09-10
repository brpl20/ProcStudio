# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  document_type       :string
#  format              :integer          default("docx"), not null
#  sign_source         :integer          default("no_signature"), not null
#  status              :integer          default("pending_review"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint
#  work_id             :bigint           not null
#
# Indexes
#
#  index_documents_on_deleted_at           (deleted_at)
#  index_documents_on_profile_customer_id  (profile_customer_id)
#  index_documents_on_work_id              (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (work_id => works.id)
#
class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :work

  has_one_attached :file # esse vai ser removido

  has_one_attached :original
  has_one_attached :signed

  validate :sign_source_restriction

  enum :document_type, {
    procuration: 'procuration',
    waiver: 'waiver',
    deficiency_statement: 'deficiency statement',
    honorary: 'honorary'
  }

  enum :format, { docx: 0, pdf: 1 }

  enum :status, { pending_review: 0, approved: 1, pending_external_signature: 2, signed: 3 }

  enum :sign_source, { no_signature: 0, manual_signature: 1, zapsign: 2 }

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
      unless sign_source.in?([
                               'manual_signature', 'zapsign'
                             ])
        errors.add(:sign_source,
                   'deve ser "manual_signature" ou "zapsign" quando o status for "signed"')
      end
    else
      unless sign_source == 'no_signature'
        errors.add(:sign_source,
                   'deve ser "no_signature" quando o status não for "signed"')
      end
    end
  end
end
