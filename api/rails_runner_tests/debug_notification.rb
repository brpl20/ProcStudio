# frozen_string_literal: true

# Debug script for notification issues
# Run with: rails runner rails_runner_tests/debug_notification.rb

puts 'Testing simple notification creation...'

begin
  user = User.first
  if !user || !user.user_profile
    puts 'No user with profile found'
    exit
  end

  notification = Notification.create!(
    user_profile: user.user_profile,
    title: 'Test',
    body: 'Test body',
    notification_type: 'info',
    read: false
  )

  puts "✅ Notification created successfully: #{notification.id}"
rescue StandardError => e
  puts '❌ Error creating notification:'
  puts e.message
  puts e.backtrace.first(5).join("\n")
end
