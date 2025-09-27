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
FactoryBot.define do
  factory :notification do
    user { nil }
    title { 'MyString' }
    body { 'MyText' }
    notification_type { 'MyString' }
    data { '' }
    read { false }
    priority { 1 }
    action_url { 'MyString' }
  end
end
