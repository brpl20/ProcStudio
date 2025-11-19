# == Schema Information
#
# Table name: file_metadata
#
#  id                :bigint           not null, primary key
#  attachable_type   :string           not null
#  byte_size         :bigint           not null
#  checksum          :string           not null
#  content_type      :string           not null
#  created_by_system :boolean          default(FALSE), not null
#  expires_at        :datetime
#  file_category     :string
#  filename          :string           not null
#  metadata          :jsonb
#  s3_key            :string           not null
#  transfer_metadata :jsonb
#  transferred_at    :datetime
#  uploaded_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  attachable_id     :bigint           not null
#  transferred_by_id :integer
#  uploaded_by_id    :bigint
#
# Indexes
#
#  index_file_metadata_on_attachable               (attachable_type,attachable_id)
#  index_file_metadata_on_attachable_and_category  (attachable_type,attachable_id,file_category)
#  index_file_metadata_on_checksum                 (checksum)
#  index_file_metadata_on_created_by_system        (created_by_system)
#  index_file_metadata_on_expires_at               (expires_at)
#  index_file_metadata_on_file_category            (file_category)
#  index_file_metadata_on_s3_key                   (s3_key) UNIQUE
#  index_file_metadata_on_transfer_metadata        (transfer_metadata) USING gin
#  index_file_metadata_on_transferred_at           (transferred_at)
#  index_file_metadata_on_transferred_by_id        (transferred_by_id)
#  index_file_metadata_on_uploaded_at              (uploaded_at)
#  index_file_metadata_on_uploaded_by_id           (uploaded_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploaded_by_id => user_profiles.id)
#
class FileMetadata < ApplicationRecord
  # File categories
  FILE_CATEGORIES = %w[
    logo avatar social_contract
    job_attachment work_document
    procuration waiver deficiency_statement honorary
    customer_document temp_upload
  ].freeze

  # Polymorphic association to any model
  belongs_to :attachable, polymorphic: true
  belongs_to :uploaded_by, class_name: 'UserProfile', optional: true

  # Callbacks
  before_destroy :delete_from_s3

  # Validations
  validates :s3_key, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :byte_size, presence: true, numericality: { greater_than: 0 }
  validates :checksum, presence: true
  validates :file_category, inclusion: { in: FILE_CATEGORIES }, allow_nil: true

  # Scopes
  scope :system_generated, -> { where(created_by_system: true) }
  scope :user_uploaded, -> { where(created_by_system: false) }
  scope :by_category, ->(category) { where(file_category: category) }
  scope :temporary, -> { where.not(expires_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :permanent, -> { where(expires_at: nil) }

  # Generate URL for file access
  def url(type: :view, expires_in: 3600)
    S3Manager.url(self, type: type, expires_in: expires_in)
  end

  # Check if file was created by system
  def system_generated?
    created_by_system
  end

  # Check if file was uploaded by user
  def user_uploaded?
    !created_by_system
  end

  # Check if file is temporary
  def temporary?
    expires_at.present?
  end

  # Check if file has expired
  def expired?
    temporary? && expires_at < Time.current
  end

  # Helper method to get User from UserProfile
  def user
    uploaded_by&.user
  end

  private

  # Delete file from S3 before destroying the record
  def delete_from_s3
    S3Manager.delete(self)
  rescue StandardError => e
    Rails.logger.error "Failed to delete file from S3: #{e.message}"
    Rails.logger.error "File: #{s3_key}"
    # Don't prevent deletion of database record even if S3 deletion fails
    true
  end
end
