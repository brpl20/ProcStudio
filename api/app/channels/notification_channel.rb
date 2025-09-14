# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    if current_user && current_user.user_profile
      stream_for current_user
      
      # Send initial unread count on subscription
      transmit({
        type: 'connection_established',
        unread_count: current_user.user_profile.notifications.unread.count
      })
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def mark_as_read(data)
    notification = current_user.user_profile.notifications.find_by(id: data['notification_id'])
    
    if notification
      notification.mark_as_read!
      transmit({
        type: 'notification_marked_as_read',
        notification_id: notification.id,
        unread_count: current_user.user_profile.notifications.unread.count
      })
    end
  end

  def mark_all_as_read
    current_user.user_profile.notifications.unread.update_all(read: true)
    
    transmit({
      type: 'all_notifications_marked_as_read',
      unread_count: 0
    })
  end

  def request_unread_count
    transmit({
      type: 'unread_count_update',
      unread_count: current_user.user_profile.notifications.unread.count
    })
  end
end