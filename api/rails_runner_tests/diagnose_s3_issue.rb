# frozen_string_literal: true

puts "=" * 60
puts "S3 CONFIGURATION DIAGNOSTIC"
puts "=" * 60
puts

# Step 1: Check raw environment
puts "1. RAW ENVIRONMENT VARIABLES (before dotenv):"
puts "-" * 40
['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_BUCKET_MAIN', 'AWS_DEFAULT_REGION', 'S3_BUCKET'].each do |key|
  value = ENV[key]
  if value
    masked = key.include?('SECRET') ? '***' : value[0..10] + '...'
    puts "   #{key} = #{masked}"
  else
    puts "   #{key} = NOT SET"
  end
end

# Step 2: Load dotenv
puts "\n2. LOADING DOTENV:"
puts "-" * 40
require 'dotenv'
env_file = Rails.root.join('.env')
if File.exist?(env_file)
  puts "   Found .env at: #{env_file}"
  Dotenv.load(env_file)
  puts "   ✅ Dotenv loaded"
else
  puts "   ❌ .env file not found at: #{env_file}"
end

# Step 3: Check environment after dotenv
puts "\n3. ENVIRONMENT AFTER DOTENV:"
puts "-" * 40
['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_BUCKET_MAIN', 'AWS_DEFAULT_REGION', 'S3_BUCKET'].each do |key|
  value = ENV[key]
  if value
    masked = key.include?('SECRET') ? '***' : value[0..10] + '...'
    puts "   #{key} = #{masked}"
  else
    puts "   #{key} = NOT SET"
  end
end

# Step 4: Check Office model S3 configuration
puts "\n4. OFFICE MODEL S3 CONFIGURATION:"
puts "-" * 40

# Create a test office to check its S3 configuration
team = Team.first || Team.create!(name: 'Test Team')
office = team.offices.build(name: 'Test Office', cnpj: '11.222.333/0001-81')

puts "   S3 Bucket Expected: #{ENV['S3_BUCKET'] || 'NOT SET'}"
puts "   AWS Bucket Main: #{ENV['AWS_BUCKET_MAIN'] || 'NOT SET'}"
puts "   AWS Region: #{ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'NOT SET'}"

# Check if S3 client can be created
begin
  require 'aws-sdk-s3'
  
  # Try to create S3 client as Office model does
  s3_client = Aws::S3::Client.new(
    region: ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1',
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )
  
  puts "\n5. S3 CLIENT CREATION:"
  puts "-" * 40
  puts "   ✅ S3 client created successfully"
  
  # Check bucket access
  bucket = ENV['S3_BUCKET'] || ENV['AWS_BUCKET_MAIN']
  if bucket
    begin
      s3_client.head_bucket(bucket: bucket)
      puts "   ✅ Bucket '#{bucket}' is accessible"
    rescue Aws::S3::Errors::NotFound
      puts "   ❌ Bucket '#{bucket}' not found"
    rescue Aws::S3::Errors::Forbidden
      puts "   ❌ Access forbidden to bucket '#{bucket}'"
    rescue => e
      puts "   ❌ Error accessing bucket: #{e.message}"
    end
  else
    puts "   ❌ No bucket configured"
  end
  
rescue => e
  puts "\n5. S3 CLIENT CREATION:"
  puts "-" * 40
  puts "   ❌ Failed to create S3 client: #{e.message}"
end

# Step 6: Check what the Office model actually uses
puts "\n6. OFFICE MODEL BEHAVIOR:"
puts "-" * 40

# Check the upload_logo method behavior
if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_BUCKET'].present?
  puts "   ✅ Office model WILL use S3 storage"
  puts "   S3 Path pattern: #{Rails.env}/team-#{team.id}/offices/[office_id]/..."
else
  puts "   ⚠️  Office model will use LOCAL storage mode"
  puts "   Local path pattern: local/#{Rails.env}/team-#{team.id}/offices/[office_id]/..."
  missing = []
  missing << 'AWS_ACCESS_KEY_ID' unless ENV['AWS_ACCESS_KEY_ID'].present?
  missing << 'AWS_SECRET_ACCESS_KEY' unless ENV['AWS_SECRET_ACCESS_KEY'].present?
  missing << 'S3_BUCKET' unless ENV['S3_BUCKET'].present?
  puts "   Missing variables: #{missing.join(', ')}"
end

puts "\n" + "=" * 60
puts "SUMMARY:"
puts "=" * 60

# Final diagnosis
if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_BUCKET'].present?
  puts "✅ S3 is properly configured for uploads"
elsif ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['AWS_BUCKET_MAIN'].present?
  puts "⚠️  You have AWS credentials but using AWS_BUCKET_MAIN instead of S3_BUCKET"
  puts "    The Office model expects S3_BUCKET to be set"
  puts "    Solution: Add to your .env file: S3_BUCKET=#{ENV['AWS_BUCKET_MAIN']}"
else
  puts "❌ S3 is not configured - using local file storage"
end

puts "=" * 60