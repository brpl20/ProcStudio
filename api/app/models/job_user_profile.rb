# frozen_string_literal: true

# == Schema Information
#
# Table name: job_user_profiles
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  role            :string           default("assignee")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  job_id          :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_job_user_profiles_on_deleted_at                  (deleted_at)
#  index_job_user_profiles_on_job_id                      (job_id)
#  index_job_user_profiles_on_job_id_and_user_profile_id  (job_id,user_profile_id) UNIQUE
#  index_job_user_profiles_on_user_profile_id             (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (job_id => jobs.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class JobUserProfile < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :job
  belongs_to :user_profile

  validates :job_id, uniqueness: { scope: :user_profile_id }
  validate :user_profile_same_team
  validate :user_profile_belongs_to_team

  enum :role, {
    assignee: 'assignee',       # Responsável principal
    supervisor: 'supervisor',   # Supervisor do job
    reviewer: 'reviewer',       # Revisor
    collaborator: 'collaborator' # Colaborador
  }

  scope :active, -> { where(deleted_at: nil) }

  private

  def user_profile_same_team
    return unless job&.team && user_profile&.user&.team

    return if job.team == user_profile.user.team

    errors.add(:user_profile, :same_team_required)
  end

  def user_profile_belongs_to_team
    return unless user_profile&.user

    return if user_profile.user.team.present?

    errors.add(:user_profile, :team_required)
  end
end
