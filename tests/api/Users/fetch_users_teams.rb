#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../../config/environment'
require 'json'

output_file = File.join(File.dirname(__FILE__), 'users_teams_data.json')

users_data = User.includes(:team, :user_profile).map do |user|
  {
    id: user.id,
    email: user.email,
    status: user.status,
    oab: user.oab,
    team_id: user.team_id,
    team_name: user.team.name,
    team_subdomain: user.team.subdomain,
    profile_name: user.user_profile&.name,
    role: user.role,
    created_at: user.created_at.iso8601
  }
end

teams_summary = users_data.group_by { |u| u[:team_id] }.transform_values do |team_users|
  {
    team_name: team_users.first[:team_name],
    team_subdomain: team_users.first[:team_subdomain],
    users: team_users.map { |u| { email: u[:email], id: u[:id] } }
  }
end

result = {
  generated_at: Time.current.iso8601,
  total_users: users_data.count,
  users: users_data,
  teams_summary: teams_summary
}

File.write(output_file, JSON.pretty_generate(result))

puts JSON.generate({
                     success: true,
                     message: 'Data exported successfully',
                     file: output_file,
                     total_users: users_data.count,
                     total_teams: teams_summary.count
                   })
