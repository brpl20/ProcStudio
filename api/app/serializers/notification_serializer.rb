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
#  priority          :string           default("0")
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
#  index_notifications_on_created_at                 (created_at)
#  index_notifications_on_notification_type          (notification_type)
#  index_notifications_on_priority                   (priority)
#  index_notifications_on_read                       (read)
#  index_notifications_on_sender_type_and_sender_id  (sender_type,sender_id)
#  index_notifications_on_user_profile_id            (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class NotificationSerializer
  include JSONAPI::Serializer

  attributes :id,
             :title,
             :body,
             :notification_type,
             :data,
             :read,
             :action_url,
             :created_at,
             :updated_at
  
  attribute :priority do |notification|
    {
      value: notification.priority,
      name: notification.priority,
      numeric: Notification.priorities[notification.priority]
    }
  end

  attribute :sender do |notification|
    if notification.sender
      {
        id: notification.sender.id,
        type: notification.sender_type,
        name: notification.sender.try(:name) || notification.sender.try(:email) || notification.sender_type
      }
    end
  end

  attribute :priority_label do |notification|
    case notification.priority
    when 0 then 'low'
    when 1 then 'normal'
    when 2 then 'high'
    when 3 then 'urgent'
    else 'normal'
    end
  end

  attribute :time_ago do |notification|
    time_diff = Time.current - notification.created_at
    
    case time_diff
    when 0..59
      'agora'
    when 60..3599
      minutes = (time_diff / 60).to_i
      "#{minutes} #{minutes == 1 ? 'minuto' : 'minutos'} atrás"
    when 3600..86399
      hours = (time_diff / 3600).to_i
      "#{hours} #{hours == 1 ? 'hora' : 'horas'} atrás"
    when 86400..604799
      days = (time_diff / 86400).to_i
      "#{days} #{days == 1 ? 'dia' : 'dias'} atrás"
    else
      notification.created_at.strftime('%d/%m/%Y')
    end
  end

  belongs_to :user_profile
end
