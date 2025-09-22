#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to verify avatar_url functionality
# Usage: rails runner rails_runner_tests/test_avatar_url.rb

puts "\n=== Testing Avatar URL Generation ==="
puts "=" * 50

# Find a user with an avatar
user_profile = UserProfile.where.not(avatar_s3_key: nil).first

if user_profile.nil?
  puts "No user profiles with avatars found. Testing with first user profile..."
  user_profile = UserProfile.first
  
  if user_profile.nil?
    puts "No user profiles found in the database."
    exit 1
  end
end

puts "\nUser Profile Information:"
puts "  ID: #{user_profile.id}"
puts "  Name: #{user_profile.full_name}"
puts "  Avatar S3 Key: #{user_profile.avatar_s3_key || 'None'}"

# Test avatar_url method
puts "\n Testing avatar_url method:"
avatar_url = user_profile.avatar_url

if avatar_url.nil?
  puts "  ❌ No avatar URL generated (avatar_s3_key is blank or nil)"
else
  puts "  ✅ Avatar URL generated successfully"
  puts "  URL: #{avatar_url[0..100]}..." # Show first 100 chars
  
  # Check URL structure
  if avatar_url.include?('https://') && avatar_url.include?('.amazonaws.com')
    puts "  ✅ URL appears to be valid S3 presigned URL"
  else
    puts "  ⚠️ URL format doesn't look like standard S3 presigned URL"
  end
  
  # Check for expiration parameter
  if avatar_url.include?('X-Amz-Expires=')
    puts "  ✅ URL includes expiration parameter"
  else
    puts "  ⚠️ URL doesn't include expiration parameter"
  end
end

# Test serializer
puts "\n Testing UserProfileSerializer:"
begin
  serialized = UserProfileSerializer.new(user_profile).serializable_hash
  avatar_from_serializer = serialized.dig(:data, :attributes, :avatar_url)
  
  if avatar_from_serializer == avatar_url
    puts "  ✅ Serializer returns same URL as model method"
  else
    puts "  ❌ Serializer URL doesn't match model method"
    puts "    Model: #{avatar_url}"
    puts "    Serializer: #{avatar_from_serializer}"
  end
rescue => e
  puts "  ❌ Error testing serializer: #{e.message}"
end

# Test with multiple profiles
puts "\n Testing multiple profiles with avatars:"
profiles_with_avatars = UserProfile.where.not(avatar_s3_key: nil).limit(5)

if profiles_with_avatars.any?
  profiles_with_avatars.each do |profile|
    url = profile.avatar_url
    status = url.present? ? "✅" : "❌"
    puts "  #{status} Profile ##{profile.id} (#{profile.name}): #{url.present? ? 'URL generated' : 'No URL'}"
  end
else
  puts "  No profiles with avatars found in database"
end

puts "\n" + "=" * 50
puts "Test completed successfully!"