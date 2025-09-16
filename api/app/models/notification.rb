# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  action_url        :string
#  body              :text
#  data              :jsonb
#  notification_type :string
#  priority          :integer          default("normal")
#  read              :boolean          default(FALSE)
#  sender_type       :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sender_id         :bigint
#  user_profile_id   :bigint
#
# Indexes
#
#  index_notifications_on_created_at                     (created_at)
#  index_notifications_on_notification_type              (notification_type)
#  index_notifications_on_priority                       (priority)
#  index_notifications_on_read                           (read)
#  index_notifications_on_sender_type_and_sender_id      (sender_type,sender_id)
#  index_notifications_on_user_profile_id                (user_profile_id)
#  index_notifications_on_user_profile_priority_created  (user_profile_id,priority,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
# Please update related docs when updating model
# Docs => Notifications.md

class Notification < ApplicationRecord
  belongs_to :user_profile
  belongs_to :sender, polymorphic: true, optional: true

  TYPES = %w[
    info
    success
    warning
    error
    system
    user_action
    process_update
    task_assignment
    compliance
  ].freeze

  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }, default: :normal

  validates :title, presence: true
  validates :notification_type, presence: true, inclusion: { in: TYPES }

  scope :unread, -> { where(read: false) }
  scope :by_priority, -> { order(priority: :desc, created_at: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user_profile, ->(user_profile) { where(user_profile: user_profile) }

  after_create_commit :broadcast_notification

  def mark_as_read!
    update!(read: true)
  end

  def mark_as_unread!
    update!(read: false)
  end

  def high_priority?
    high? || urgent?
  end

  private

  def broadcast_notification
    NotificationChannel.broadcast_to(
      user_profile.user,
      NotificationSerializer.new(self).serializable_hash[:data][:attributes]
    )
  end
end
