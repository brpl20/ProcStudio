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
#  user_profile_id   :bigint
#
# Indexes
#
#  index_notifications_on_created_at                 (created_at)
#  index_notifications_on_notification_type          (notification_type)
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
  include ActionView::Helpers::DateHelper

  attributes :id,
             :title,
             :body,
             :notification_type,
             :data,
             :read,
             :action_url,
             :created_at,
             :updated_at

  attribute :sender do |notification|
    if notification.sender
      {
        id: notification.sender.id,
        type: notification.sender_type,
        name: notification.sender.try(:name) || notification.sender.try(:email) || notification.sender_type
      }
    end
  end

  attribute :time_ago do |notification|
    if notification.created_at > 7.days.ago
      I18n.with_locale(:'pt-BR') do
        "#{time_ago_in_words(notification.created_at)} atrás"
      end
    else
      notification.created_at.strftime('%d/%m/%Y')
    end
  end

  belongs_to :user_profile
end
