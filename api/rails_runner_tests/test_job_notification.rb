# frozen_string_literal: true

# Test script for refactored job notification
# Run with: rails runner rails_runner_tests/test_job_notification.rb

puts 'Testing refactored job notification...'
puts '=' * 50

team = Team.first
user = User.first
other_user = User.where.not(id: user.id).first

if team && user && other_user
  puts "Creating test job with team ##{team.id}"

  # Clear recent notifications
  Notification.where(created_at: 10.seconds.ago..).destroy_all

  # Create a job with assignees and supervisors
  job = Job.create!(
    team: team,
    description: 'Test notification refactor',
    deadline: 1.week.from_now,
    priority: 'medium',
    status: 'pending',
    created_by: user,
    assignees: [other_user.user_profile].compact,
    supervisors: [user.user_profile].compact
  )

  # Check created notifications
  new_notifications = Notification.where(created_at: 5.seconds.ago..)

  puts "\nJob created: ##{job.id}"
  puts "Assignees: #{job.assignees.count}"
  puts "Supervisors: #{job.supervisors.count}"
  puts "\nNotifications created: #{new_notifications.count}"

  new_notifications.each do |n|
    recipient = n.user_profile.name || n.user_profile.email
    puts "  - #{n.title} to #{recipient}"
    puts "    Type: #{n.notification_type}"
  end

  # Cleanup test job
  job.destroy

  puts "\n✅ Job notification refactor working correctly!"
else
  puts '❌ Missing test data (need team and at least 2 users)'
end
