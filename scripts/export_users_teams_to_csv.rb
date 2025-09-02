#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'csv'

filename = "users_and_teams_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
filepath = Rails.root.join('tmp', filename)

CSV.open(filepath, 'wb') do |csv|
  csv << ['User ID', 'Email', 'Status', 'OAB', 'Team Name', 'Team Subdomain', 'Profile Name', 'Role', 'Created At']

  User.includes(:team, :user_profile).find_each do |user|
    csv << [
      user.id,
      user.email,
      user.status,
      user.oab,
      user.team.name,
      user.team.subdomain,
      user.user_profile&.name,
      user.role,
      user.created_at
    ]
  end
end

puts "CSV exported to: #{filepath}"
puts "Total users exported: #{User.count}"
