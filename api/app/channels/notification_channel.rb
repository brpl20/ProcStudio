# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    if current_user&.user_profile
      stream_for current_user

      # Send initial unread count on subscription (team-scoped)
      team = current_user.team
      transmit({
                 type: 'connection_established',
                 unread_count: current_user.user_profile.notifications.for_team(team).unread.count
               })
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def mark_as_read(data)
    team = current_user.team
    notification = current_user.user_profile.notifications.for_team(team).find_by(id: data['notification_id'])

    return unless notification

    notification.mark_as_read!
    transmit({
               type: 'notification_marked_as_read',
               notification_id: notification.id,
               unread_count: current_user.user_profile.notifications.for_team(team).unread.count
             })
  end

  def mark_all_as_read
    team = current_user.team
    current_user.user_profile.notifications.for_team(team).unread.update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

    transmit({
               type: 'all_notifications_marked_as_read',
               unread_count: 0
             })
  end

  def request_unread_count
    team = current_user.team
    transmit({
               type: 'unread_count_update',
               unread_count: current_user.user_profile.notifications.for_team(team).unread.count
             })
  end
end
