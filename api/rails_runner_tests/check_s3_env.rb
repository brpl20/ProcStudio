# frozen_string_literal: true

# Load dotenv if not already loaded
require 'dotenv'
Dotenv.load('.env', '.env.local')

puts '=' * 60
puts 'S3 ENVIRONMENT CHECK'
puts '=' * 60
puts

# Check all possible S3/AWS environment variables
env_vars = {
  'AWS_ACCESS_KEY_ID' => ENV.fetch('AWS_ACCESS_KEY_ID', nil),
  'AWS_SECRET_ACCESS_KEY' => ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
  'S3_BUCKET' => ENV.fetch('S3_BUCKET', nil),
  'AWS_BUCKET_MAIN' => ENV.fetch('AWS_BUCKET_MAIN', nil),
  'AWS_REGION' => ENV.fetch('AWS_REGION', nil),
  'AWS_DEFAULT_REGION' => ENV.fetch('AWS_DEFAULT_REGION', nil)
}

env_vars.each do |key, value|
  if value.present?
    masked = key.include?('SECRET') ? ('*' * 8) : "#{value.to_s[0..15]}..."
    puts "✅ #{key}: #{masked}"
  else
    puts "❌ #{key}: NOT SET"
  end
end

puts
puts 'Effective S3 Configuration:'
puts '-' * 40
bucket = ENV['S3_BUCKET'] || ENV.fetch('AWS_BUCKET_MAIN', nil)
region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'

if bucket.present? && ENV['AWS_ACCESS_KEY_ID'].present?
  puts '✅ S3 appears to be configured'
  puts "   Bucket: #{bucket}"
  puts "   Region: #{region}"

  # Try to test S3 connection
  require 'aws-sdk-s3'
  begin
    client = Aws::S3::Client.new(
      region: region,
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    )

    client.head_bucket(bucket: bucket)
    puts '   Status: Connected successfully! ✅'
  rescue StandardError => e
    puts "   Status: Connection failed - #{e.message} ❌"
  end
else
  puts '❌ S3 is NOT properly configured'
  puts '   Missing critical environment variables'
  puts '   The app will use LOCAL FILE STORAGE mode'
end

puts
puts '=' * 60
