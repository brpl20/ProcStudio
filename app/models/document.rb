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
#
class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :work

  has_one_attached :file

  validate :sign_source_restriction

  enum document_type: {
    procuration: 'procuration',
    waiver: 'waiver',
    deficiency_statement: 'deficiency statement',
    honorary: 'honorary'
  }

  enum format: [:docx, :pdf]

  enum status: [:pending_review, :approved, :signed]

  enum sign_source: [:no_signature, :manual_signature, :zap_sign]

  scope :procurations, -> { where(document_type: 'procuration') }

  def mark_as_pdf_and_approved
    update(format: :pdf, status: :approved)
  end

  private

  def sign_source_restriction
    if status == :signed
      errors.add(:sign_source, 'deve ser "manual_signature" ou "zap_sign" quando o status for "signed"') unless sign_source.in?(%w[manual_signature zap_sign])
    else
      errors.add(:sign_source, 'deve ser "no_signature" quando o status não for "signed"') unless sign_source == 'no_signature'
    end
  end
end
