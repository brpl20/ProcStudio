# frozen_string_literal: true

# Test S3 Phase 1 Implementation
# Run with: rails runner rails_runner_tests/test_s3_phase1.rb

puts 'Testing S3 Phase 1 Implementation...'
puts '=' * 50

# Test S3Service
puts "\n1. Testing S3Service:"
puts '-' * 30

# Check if S3 is configured
if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['S3_BUCKET'].present?
  puts '✓ S3 credentials configured'
  puts "  Bucket: #{ENV.fetch('S3_BUCKET', nil)}"
  puts "  Region: #{ENV['AWS_REGION'] || 'us-west-2'}"
else
  puts '✗ S3 credentials not configured'
  puts '  Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and S3_BUCKET'
end

# Test S3PathBuilder
puts "\n2. Testing S3PathBuilder:"
puts '-' * 30

office = Office.first
if office
  puts "✓ Testing with Office ##{office.id} (Team ##{office.team_id})"

  # Test path generation
  logo_key = office.build_logo_s3_key('png')
  puts "  Logo path: #{logo_key}"

  contract_key = office.build_social_contract_s3_key('pdf')
  puts "  Contract path: #{contract_key}"

  # Verify path structure
  expected_prefix = "#{Rails.env}/team-#{office.team_id}"
  if logo_key.start_with?(expected_prefix)
    puts '✓ Path structure correct'
  else
    puts '✗ Path structure incorrect'
  end
else
  puts '✗ No office found to test with'
end

user_profile = UserProfile.first
if user_profile
  puts "\n✓ Testing with UserProfile ##{user_profile.id}"

  # Test avatar path generation
  avatar_key = user_profile.build_avatar_s3_key('jpg')
  puts "  Avatar path: #{avatar_key}"
else
  puts "\n✗ No user profile found to test with"
end

# Test S3Attachable
puts "\n3. Testing S3Attachable:"
puts '-' * 30

if office
  puts '✓ Office includes S3Attachable'

  # Check available methods
  methods = [:upload_logo, :logo_url, :delete_logo!,
             :upload_social_contract, :social_contracts_with_urls, :delete_social_contract!]

  methods.each do |method|
    if office.respond_to?(method)
      puts "  ✓ #{method} available"
    else
      puts "  ✗ #{method} missing"
    end
  end
else
  puts '✗ No office to test S3Attachable'
end

if user_profile
  puts "\n✓ UserProfile includes S3Attachable"

  # Check available methods
  methods = [:upload_avatar, :avatar_url, :delete_avatar!]

  methods.each do |method|
    if user_profile.respond_to?(method)
      puts "  ✓ #{method} available"
    else
      puts "  ✗ #{method} missing"
    end
  end
else
  puts '✗ No user profile to test S3Attachable'
end

# Test database columns
puts "\n4. Testing Database Columns:"
puts '-' * 30

if Office.column_names.include?('logo_s3_key')
  puts '✓ Office.logo_s3_key column exists'
else
  puts '✗ Office.logo_s3_key column missing'
end

if UserProfile.column_names.include?('avatar_s3_key')
  puts '✓ UserProfile.avatar_s3_key column exists'
else
  puts '✗ UserProfile.avatar_s3_key column missing'
end

if defined?(OfficeAttachmentMetadata)
  if OfficeAttachmentMetadata.column_names.include?('s3_key')
    puts '✓ OfficeAttachmentMetadata.s3_key column exists'
  else
    puts '✗ OfficeAttachmentMetadata.s3_key column missing'
  end
else
  puts '✗ OfficeAttachmentMetadata model not found'
end

# Test actual file upload (optional)
puts "\n5. Testing File Upload (Simulation):"
puts '-' * 30

if office && ENV['AWS_ACCESS_KEY_ID'].present?
  # Create a mock file
  require 'stringio'

  mock_file = StringIO.new('test content')
  mock_file.define_singleton_method(:original_filename) { 'test_logo.png' }
  mock_file.define_singleton_method(:content_type) { 'image/png' }
  mock_file.define_singleton_method(:size) { 12 }
  mock_file.define_singleton_method(:blank?) { false }

  puts 'Attempting to upload test logo...'

  begin
    if office.upload_logo(mock_file, uploaded_by_id: 1)
      puts '✓ Logo upload successful'
      puts "  S3 Key: #{office.logo_s3_key}"

      # Test URL generation
      url = office.logo_url
      if url
        puts '✓ Logo URL generated'
        puts "  URL (truncated): #{url[0..50]}..."
      else
        puts '✗ Failed to generate logo URL'
      end

      # Clean up
      puts '✓ Test logo deleted' if office.delete_logo!
    else
      puts '✗ Logo upload failed'
      puts "  Errors: #{office.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    puts "✗ Upload test failed: #{e.message}"
  end
else
  puts '⚠ Skipping actual upload test (S3 not configured or no office)'
end

puts "\n#{'=' * 50}"
puts 'Phase 1 Implementation Test Complete!'
puts '=' * 50
