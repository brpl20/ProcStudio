# frozen_string_literal: true

# Test script for the new centralized NotificationService
# Run with: rails runner rails_runner_tests/test_notification_service.rb

puts '=' * 50
puts 'Testing Centralized NotificationService'
puts '=' * 50

# Get test data
team = Team.first
user = User.first
user_profile = user&.user_profile

if !team || !user || !user_profile
  puts '❌ Missing test data. Please ensure you have at least one team and user with profile.'
  exit
end

puts "\n1. Testing basic notification:"
puts '-' * 30

notification = NotificationService.notify(
  recipients: user_profile,
  title: 'Test Notification',
  body: 'This is a test of the centralized notification system',
  type: 'info',
  data: { test: true }
)

if notification&.persisted?
  puts '✅ Basic notification created successfully'
  puts "   ID: #{notification.id}"
  puts "   Title: #{notification.title}"
  puts "   Type: #{notification.notification_type}"
else
  puts '❌ Failed to create basic notification'
end

puts "\n2. Testing team notification (all members):"
puts '-' * 30

team_notifications = NotificationService.notify_team(
  team: team,
  title: 'Team Announcement',
  body: 'This message goes to all team members',
  scope: :all
)

if team_notifications&.any?
  puts "✅ Team notifications created: #{team_notifications.count} notifications"
else
  puts '❌ Failed to create team notifications'
end

puts "\n3. Testing team notification (lawyers only):"
puts '-' * 30

lawyer_notifications = NotificationService.notify_team(
  team: team,
  title: 'Legal Update',
  body: 'This message goes only to lawyers',
  scope: :lawyers,
  type: 'compliance'
)

lawyer_count = team.users.joins(:user_profile).where(user_profiles: { role: 'lawyer' }).count
if lawyer_notifications
  actual_count = lawyer_notifications.is_a?(Array) ? lawyer_notifications.count : 1
  puts "✅ Lawyer notifications created: #{actual_count} (expected: #{lawyer_count})"
else
  puts '❌ Failed to create lawyer notifications'
end

puts "\n4. Testing job task assignment notification:"
puts '-' * 30

job = Job.first
if job
  task_notification = NotificationService.notify_task_assignment(
    job: job,
    assignees: [user_profile],
    title: 'Task Assigned',
    body: "You have been assigned to task ##{job.id}"
  )

  if task_notification
    puts '✅ Task assignment notification created'
  else
    puts '❌ Failed to create task assignment notification'
  end
else
  puts '⚠️  No jobs found to test task assignment'
end

puts "\n5. Testing capacity change notification:"
puts '-' * 30

profile_customer = ProfileCustomer.first
if profile_customer && profile_customer.customer&.teams&.first
  capacity_notification = NotificationService.notify_capacity_change(
    profile_customer: profile_customer,
    old_capacity: 'able',
    new_capacity: 'relatively',
    reason: 'test'
  )

  if capacity_notification
    puts '✅ Capacity change notification created'
  else
    puts '❌ Failed to create capacity change notification'
  end
else
  puts '⚠️  No profile customers with teams found to test capacity change'
end

puts "\n6. Testing representation change notification:"
puts '-' * 30

represent = Represent.first
if represent&.team
  rep_notification = NotificationService.notify_representation_change(
    represent: represent,
    notification_type: 'new_representation'
  )

  if rep_notification
    puts '✅ Representation change notification created'
  else
    puts '❌ Failed to create representation change notification'
  end
else
  puts '⚠️  No representations with teams found to test'
end

puts "\n#{'=' * 50}"
puts 'Notification Service Test Complete!'
puts '=' * 50

# Summary
total_notifications = Notification.where(created_at: 1.minute.ago..).count
puts "\nSummary:"
puts "Total notifications created in this test: #{total_notifications}"
puts "Notification types in system: #{Notification::TYPES.join(', ')}"
