#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

puts "\n#{'=' * 60}"
puts 'FETCHING ALL USERS AND THEIR TEAMS'
puts "#{'=' * 60}\n"

users = User.includes(:team, :user_profile).all

if users.empty?
  puts 'No users found in the database.'
else
  users.each_with_index do |user, index|
    puts "\n#{index + 1}. User Information:"
    puts "   Email: #{user.email}"
    puts "   Status: #{user.status}"
    puts "   OAB: #{user.oab || 'N/A'}"
    puts "   Team: #{user.team.name}"
    puts "   Team Subdomain: #{user.team.subdomain}"

    if user.user_profile
      puts "   Profile Name: #{begin
        user.user_profile.name
      rescue StandardError
        'N/A'
      end}"
      puts "   Role: #{user.role || 'N/A'}"
    end

    puts '-' * 40
  end

  puts "\n#{'=' * 60}"
  puts 'SUMMARY'
  puts '=' * 60
  puts "Total Users: #{users.count}"

  team_counts = users.group_by(&:team).transform_values(&:count)
  puts "\nUsers per Team:"
  team_counts.each do |team, count|
    puts "  - #{team.name} (#{team.subdomain}): #{count} user(s)"
  end
end

puts "\n"
