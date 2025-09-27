# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  action_url        :string
#  body              :text
#  data              :jsonb
#  notification_type :string
#  read              :boolean          default(FALSE)
#  sender_type       :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sender_id         :bigint
#  team_id           :bigint           not null
#  user_profile_id   :bigint
#
# Indexes
#
#  index_notifications_on_created_at                 (created_at)
#  index_notifications_on_notification_type          (notification_type)
#  index_notifications_on_read                       (read)
#  index_notifications_on_sender_type_and_sender_id  (sender_type,sender_id)
#  index_notifications_on_team_id                    (team_id)
#  index_notifications_on_user_profile_id            (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
# Please update related docs when updating model
# Docs => Notifications.md

class Notification < ApplicationRecord
  belongs_to :user_profile
  belongs_to :team
  belongs_to :sender, polymorphic: true, optional: true

  TYPES = [
    'info',
    'success',
    'warning',
    'error',
    'system',
    'user_action',
    'process_update',
    'task_assignment',
    'compliance',
    'capacity_change',
    'age_transition',
    'representation_change',
    'document_update',
    'deadline_reminder'
  ].freeze

  validates :title, presence: true
  validates :notification_type, presence: true, inclusion: { in: TYPES }

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user_profile, ->(user_profile) { where(user_profile: user_profile) }
  scope :for_team, ->(team) { where(team: team) }

  after_create_commit :broadcast_notification

  def mark_as_read!
    update!(read: true)
  end

  def mark_as_unread!
    update!(read: false)
  end

  private

  def broadcast_notification
    NotificationChannel.broadcast_to(
      user_profile.user,
      NotificationSerializer.new(self).serializable_hash[:data][:attributes]
    )
  end
end
