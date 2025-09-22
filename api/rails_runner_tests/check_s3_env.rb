# frozen_string_literal: true

# Load dotenv if not already loaded
require 'dotenv'
Dotenv.load('.env', '.env.local')

puts "=" * 60
puts "S3 ENVIRONMENT CHECK"
puts "=" * 60
puts

# Check all possible S3/AWS environment variables
env_vars = {
  'AWS_ACCESS_KEY_ID' => ENV['AWS_ACCESS_KEY_ID'],
  'AWS_SECRET_ACCESS_KEY' => ENV['AWS_SECRET_ACCESS_KEY'],
  'S3_BUCKET' => ENV['S3_BUCKET'],
  'AWS_BUCKET_MAIN' => ENV['AWS_BUCKET_MAIN'],
  'AWS_REGION' => ENV['AWS_REGION'],
  'AWS_DEFAULT_REGION' => ENV['AWS_DEFAULT_REGION']
}

env_vars.each do |key, value|
  if value.present?
    masked = key.include?('SECRET') ? ('*' * 8) : value.to_s[0..15] + '...'
    puts "✅ #{key}: #{masked}"
  else
    puts "❌ #{key}: NOT SET"
  end
end

puts
puts "Effective S3 Configuration:"
puts "-" * 40
bucket = ENV['S3_BUCKET'] || ENV['AWS_BUCKET_MAIN']
region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'

if bucket.present? && ENV['AWS_ACCESS_KEY_ID'].present?
  puts "✅ S3 appears to be configured"
  puts "   Bucket: #{bucket}"
  puts "   Region: #{region}"
  
  # Try to test S3 connection
  require 'aws-sdk-s3'
  begin
    client = Aws::S3::Client.new(
      region: region,
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    
    client.head_bucket(bucket: bucket)
    puts "   Status: Connected successfully! ✅"
  rescue => e
    puts "   Status: Connection failed - #{e.message} ❌"
  end
else
  puts "❌ S3 is NOT properly configured"
  puts "   Missing critical environment variables"
  puts "   The app will use LOCAL FILE STORAGE mode"
end

puts
puts "=" * 60