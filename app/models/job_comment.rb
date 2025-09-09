# frozen_string_literal: true

# == Schema Information
#
# Table name: job_comments
#
#  id              :bigint           not null, primary key
#  content         :text             not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  job_id          :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_job_comments_on_deleted_at             (deleted_at)
#  index_job_comments_on_job_id                 (job_id)
#  index_job_comments_on_job_id_and_created_at  (job_id,created_at)
#  index_job_comments_on_user_profile_id        (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_id => jobs.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class JobComment < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :job
  belongs_to :user_profile

  validates :content, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  delegate :full_name, to: :user_profile, prefix: true
  delegate :avatar, to: :user_profile, allow_nil: true

  def author_name
    user_profile.full_name
  end

  def author_avatar_url
    return nil unless user_profile.avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(user_profile.avatar)
  rescue StandardError
    nil
  end
end
