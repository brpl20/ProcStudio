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
class JobCommentSerializer
  include JSONAPI::Serializer

  attributes :content, :created_at, :updated_at

  attribute :author do |object|
    {
      id: object.user_profile.id,
      name: object.user_profile.full_name,
      avatar_url: if object.user_profile.avatar.attached?
                    Rails.application.routes.url_helpers.rails_blob_url(object.user_profile.avatar, only_path: true)
                  end
    }
  end

  belongs_to :job
  belongs_to :user_profile
end
