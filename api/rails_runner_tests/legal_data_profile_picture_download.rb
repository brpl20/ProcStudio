#!/usr/bin/env ruby
# frozen_string_literal: true

# Standalone test to verify profile picture download capability
# Usage: ruby test_profile_picture_download.rb

require 'net/http'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'aws-sdk-s3'

class ProfilePictureTest
  def initialize(url)
    @url = url
    @test_dir = Rails.root.join('tmp/profile_picture_test')
    FileUtils.mkdir_p(@test_dir)

    # Initialize AWS S3 client using system credentials
    @s3_client = Aws::S3::Client.new(region: 'us-west-2')
  end

  def run_tests
    puts "\n#{'=' * 60}"
    puts 'PROFILE PICTURE DOWNLOAD TEST'
    puts '=' * 60
    puts "\nTesting URL: #{@url}"
    puts '-' * 60

    test_basic_connectivity
    test_with_aws_s3
    test_download_to_file

    puts "\n#{'=' * 60}"
    puts 'TEST SUMMARY'
    puts '=' * 60
    cleanup
  end

  private

  def test_basic_connectivity
    print "\n1. Testing WITHOUT authentication... "
    uri = URI(@url)
    response = Net::HTTP.get_response(uri)

    if response.code == '200'
      puts '✅ SUCCESS'
      puts "   - Status: #{response.code}"
      puts "   - Content-Type: #{response['Content-Type']}"
      puts "   - Content-Length: #{response['Content-Length']} bytes"
    else
      puts '❌ FAILED'
      puts "   - Status: #{response.code}"
      puts "   - Message: #{response.message}"
    end
  rescue StandardError => e
    puts "❌ ERROR: #{e.message}"
  end

  def test_with_aws_s3
    print "\n2. Testing with AWS S3 SDK... "

    # Parse S3 URL to extract bucket and key
    uri = URI(@url)
    bucket_name = uri.host.split('.')[0] # Extract bucket name from subdomain
    object_key = uri.path[1..] # Remove leading slash

    response = @s3_client.get_object(bucket: bucket_name, key: object_key)
    content = response.body.read

    puts '✅ SUCCESS'
    puts "   - Downloaded #{content.bytesize} bytes"
    puts "   - Content-Type: #{response.content_type}"
    puts "   - Last Modified: #{response.last_modified}"
  rescue Aws::S3::Errors::ServiceError => e
    puts "❌ AWS S3 ERROR: #{e.message}"
  rescue StandardError => e
    puts "❌ ERROR: #{e.message}"
  end

  def test_download_to_file
    print "\n3. Testing download to file... "

    filename = File.join(@test_dir, 'test_profile.jpg')

    URI.open(@url) do |image|
      File.binwrite(filename, image.read)
    end

    if File.exist?(filename)
      size = File.size(filename)
      puts '✅ SUCCESS'
      puts "   - File saved to: #{filename}"
      puts "   - File size: #{size} bytes"

      # Check if it's a valid image
      puts '   - File appears to be valid (non-zero size)' if size.positive?
    else
      puts '❌ FAILED - File not created'
    end
  rescue StandardError => e
    puts "❌ ERROR: #{e.message}"
  end

  def cleanup
    print "\nCleaning up test files... "
    FileUtils.rm_rf(@test_dir)
    puts '✅ Done'
  end
end

# Run in Rails context
if defined?(Rails)
  url = 'https://oabapi-profile-pic.s3.amazonaws.com/PR_54161_profile_pic.jpg'

  # You can also test with a profile picture from your database
  # user = User.find_by(oab: 'PR_54161')
  # url = user.profile_picture_url if user&.profile_picture_url

  tester = ProfilePictureTest.new(url)
  tester.run_tests
else
  puts 'This script must be run in Rails context:'
  puts 'rails runner test_profile_picture_download.rb'
end
