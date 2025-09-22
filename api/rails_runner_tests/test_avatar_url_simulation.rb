#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to simulate avatar URL generation
# Usage: rails runner rails_runner_tests/test_avatar_url_simulation.rb

puts "\n=== Testing Avatar URL Generation (Simulation) ==="
puts "=" * 50

# Get first user profile
user_profile = UserProfile.first

if user_profile.nil?
  puts "No user profiles found in the database."
  exit 1
end

puts "\nUser Profile Information:"
puts "  ID: #{user_profile.id}"
puts "  Name: #{user_profile.full_name}"
puts "  Current Avatar S3 Key: #{user_profile.avatar_s3_key || 'None'}"

# Simulate having an avatar S3 key
puts "\n Simulating avatar upload (setting temporary S3 key)..."
original_s3_key = user_profile.avatar_s3_key
test_s3_key = "teams/#{user_profile.user.team_id}/users/#{user_profile.id}/avatar/test-avatar-#{Time.now.to_i}.jpg"

user_profile.update_column(:avatar_s3_key, test_s3_key)
puts "  Set temporary S3 key: #{test_s3_key}"

# Test avatar_url method
puts "\n Testing avatar_url method:"
avatar_url = user_profile.avatar_url

if avatar_url.nil?
  puts "  ❌ No avatar URL generated"
else
  puts "  ✅ Avatar URL generated successfully"
  
  # Parse URL to show components
  begin
    uri = URI.parse(avatar_url)
    puts "\n  URL Components:"
    puts "    Protocol: #{uri.scheme}"
    puts "    Host: #{uri.host}"
    puts "    Path: #{uri.path}"
    
    # Parse query parameters
    if uri.query
      params = CGI.parse(uri.query)
      puts "\n  Query Parameters:"
      params.each do |key, value|
        if key.include?('Signature')
          puts "    #{key}: [REDACTED]"
        else
          puts "    #{key}: #{value.first}"
        end
      end
    end
  rescue => e
    puts "  Error parsing URL: #{e.message}"
  end
end

# Test serializer output
puts "\n Testing UserProfileSerializer output:"
begin
  serialized = UserProfileSerializer.new(user_profile).serializable_hash
  avatar_from_serializer = serialized.dig(:data, :attributes, :avatar_url)
  
  if avatar_from_serializer.present?
    puts "  ✅ Serializer includes avatar_url in attributes"
    puts "  URL matches model method: #{avatar_from_serializer == avatar_url ? '✅ Yes' : '❌ No'}"
  else
    puts "  ❌ Serializer doesn't include avatar_url"
  end
  
  # Show full serialized attributes for debugging
  puts "\n  Serialized attributes keys:"
  serialized[:data][:attributes].keys.each do |key|
    value = serialized[:data][:attributes][key]
    if key == :avatar_url
      puts "    - #{key}: #{value.present? ? '[URL Present]' : 'nil'}"
    else
      puts "    - #{key}: #{value.class.name}"
    end
  end
rescue => e
  puts "  ❌ Error testing serializer: #{e.message}"
  puts e.backtrace[0..5]
end

# Restore original S3 key
puts "\n Restoring original S3 key..."
user_profile.update_column(:avatar_s3_key, original_s3_key)
puts "  Restored to: #{original_s3_key || 'nil'}"

puts "\n" + "=" * 50
puts "Test completed!"
puts "\nNOTE: The avatar_url method will return nil if:"
puts "  1. avatar_s3_key is blank"
puts "  2. S3 credentials are not configured"
puts "  3. S3Service.presigned_url fails"
puts "\nMake sure AWS credentials and S3_BUCKET are properly configured."