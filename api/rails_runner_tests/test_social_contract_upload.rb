# frozen_string_literal: true

# Test social contract upload
# Run with: rails runner rails_runner_tests/test_social_contract_upload.rb

require 'stringio'

puts 'Testing Social Contract Upload...'
puts '=' * 50

office = Office.last
if office
  puts "Testing with Office ##{office.id} - #{office.name}"
  puts "Team ID: #{office.team_id}"

  # Create a mock PDF file
  mock_file = StringIO.new("%PDF-1.4\nTest PDF Content")
  mock_file.define_singleton_method(:original_filename) { 'test_contract.pdf' }
  mock_file.define_singleton_method(:content_type) { 'application/pdf' }
  mock_file.define_singleton_method(:size) { mock_file.string.bytesize }
  mock_file.define_singleton_method(:blank?) { false }

  puts "\nAttempting to upload social contract..."

  metadata = {
    uploaded_by_id: 1,
    document_date: Date.current,
    description: 'Test social contract'
  }

  if office.upload_social_contract(mock_file, metadata)
    puts '✓ Social contract uploaded successfully!'

    # Check attachment metadata
    last_contract = office.attachment_metadata.where(document_type: 'social_contract').last
    if last_contract
      puts "\nContract Details:"
      puts "  ID: #{last_contract.id}"
      puts "  S3 Key: #{last_contract.s3_key}"
      puts "  Filename: #{last_contract.filename}"
      puts "  Size: #{last_contract.byte_size} bytes"
      puts "  Uploaded by: User ##{last_contract.uploaded_by_id}"

      # Test URL generation
      contracts = office.social_contracts_with_urls
      if contracts.any?
        puts "\n✓ Social contracts with URLs generated:"
        contracts.each do |contract|
          puts "  - #{contract[:filename]}"
          puts "    URL: #{contract[:url] ? "#{contract[:url][0..50]}..." : 'N/A'}"
        end
      end

      # List S3 files for this office
      puts "\nChecking S3 for office files..."
      prefix = "#{Rails.env}/team-#{office.team_id}/offices/#{office.id}/"

      if ENV['AWS_ACCESS_KEY_ID'].present?
        files = S3Service.list_objects(prefix: prefix, max_keys: 10)
        if files.any?
          puts "Files in S3 under #{prefix}:"
          files.each do |file|
            puts "  - #{file[:key]}"
            puts "    Size: #{file[:size]} bytes"
            puts "    Modified: #{file[:last_modified]}"
          end
        else
          puts "No files found in S3 under #{prefix}"
        end
      else
        puts 'S3 not configured - cannot list files'
      end
    else
      puts '✗ Contract metadata not found'
    end
  else
    puts '✗ Social contract upload failed'
    puts "Errors: #{office.errors.full_messages.join(', ')}"
  end
else
  puts '✗ No office found to test with'
end

puts "\n#{'=' * 50}"
puts 'Test Complete!'
