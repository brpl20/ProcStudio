# frozen_string_literal: true

# == Schema Information
#
# Table name: office_attachment_metadata
#
#  id              :bigint           not null, primary key
#  custom_metadata :json
#  description     :string
#  document_date   :date
#  document_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  blob_id         :bigint           not null
#  office_id       :bigint           not null
#  uploaded_by_id  :bigint
#
# Indexes
#
#  idx_on_office_id_document_type_167734bb2a           (office_id,document_type)
#  index_office_attachment_metadata_on_blob_id         (blob_id)
#  index_office_attachment_metadata_on_office_id       (office_id)
#  index_office_attachment_metadata_on_uploaded_by_id  (uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (blob_id => active_storage_blobs.id)
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (uploaded_by_id => users.id)
#
class OfficeAttachmentMetadata < ApplicationRecord
  belongs_to :office
  belongs_to :uploaded_by, class_name: 'User', optional: true

  # Link to ActiveStorage blob
  belongs_to :blob, class_name: 'ActiveStorage::Blob'

  # Scopes
  scope :social_contracts, -> { where(document_type: 'social_contract') }
  scope :logos, -> { where(document_type: 'logo') }

  # Validations
  validates :document_type, presence: true
  validates :blob_id, uniqueness: true

  # Document types
  DOCUMENT_TYPES = ['logo', 'social_contract'].freeze

  validates :document_type, inclusion: { in: DOCUMENT_TYPES }

  # Get the attachment
  def attachment
    ActiveStorage::Attachment.find_by(blob_id: blob_id)
  end

  # Get URL for the attachment
  def url
    return nil unless blob

    Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true)
  end

  # Get download URL
  def download_url
    return nil unless blob

    Rails.application.routes.url_helpers.rails_blob_url(blob, disposition: 'attachment', only_path: true)
  end
end
