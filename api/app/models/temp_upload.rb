# == Schema Information
#
# Table name: temp_uploads
#
#  id                :bigint           not null, primary key
#  byte_size         :bigint
#  content_type      :string
#  expires_at        :datetime         not null
#  metadata          :jsonb
#  original_filename :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  team_id           :bigint           not null
#  user_profile_id   :bigint           not null
#
# Indexes
#
#  index_temp_uploads_on_expires_at                      (expires_at)
#  index_temp_uploads_on_team_id                         (team_id)
#  index_temp_uploads_on_user_profile_id                 (user_profile_id)
#  index_temp_uploads_on_user_profile_id_and_created_at  (user_profile_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class TempUpload < ApplicationRecord
  belongs_to :user_profile
  belongs_to :team
  has_one :file_metadata, as: :attachable, dependent: :destroy

  validates :original_filename, presence: true

  scope :expired, -> { joins(:file_metadata).where('file_metadata.expires_at < ?', Time.current) }

  # Set default expiration on creation
  before_validation :set_default_expiration, on: :create

  # Helper method to get User
  def user
    user_profile&.user
  end

  # Create from uploaded file
  def self.create_from_file(file, user_profile:, team:, expires_in: 7.days)
    temp = create!(
      user_profile: user_profile,
      team: team,
      original_filename: file.original_filename,
      content_type: file.content_type,
      byte_size: file.size,
      expires_at: expires_in.from_now
    )

    # Upload file via S3Manager
    metadata = S3Manager.upload(
      file,
      model: temp,
      user_profile: user_profile,
      metadata: {
        expires_at: temp.expires_at,
        file_category: 'temp_upload'
      }
    )

    temp
  end

  # Attach temporary file to a model
  def attach_to(model, **options)
    raise "File expired" if file_metadata.expired?

    # Move file to permanent location
    S3Manager.move(file_metadata, model, options)

    # Delete temp record
    destroy
  end

  private

  def set_default_expiration
    self.expires_at ||= 7.days.from_now
  end
end
