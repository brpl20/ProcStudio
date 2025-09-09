#!/usr/bin/env ruby
# frozen_string_literal: true

# S3 Cleanup Helper Script
# Usage: ruby scripts/s3_cleanup.rb [environment] [team_id]
# Examples:
#   ruby scripts/s3_cleanup.rb development        # Clean all development files
#   ruby scripts/s3_cleanup.rb development 123    # Clean team 123 files in development
#   ruby scripts/s3_cleanup.rb list              # List all development files

require 'aws-sdk-s3'
require 'dotenv'

# Load environment variables
Dotenv.load('.env', '.env.local')

class S3Cleanup
  def initialize
    @bucket = ENV.fetch('S3_BUCKET', nil)
    @s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'] || 'us-east-1',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    )
  end

  def list_files(environment = 'development', team_id = nil)
    prefix = team_id ? "#{environment}/team-#{team_id}/" : "#{environment}/"

    puts "\n📂 Listing files in S3:"
    puts "   Bucket: s3://#{@bucket}/#{prefix}\n\n"

    file_count = 0
    total_size = 0
    teams = {}

    list_objects(prefix) do |object|
      file_count += 1
      total_size += object.size

      # Extract team from path
      if (match = object.key.match(%r{#{environment}/team-(\d+)/}))
        team_id = match[1]
        teams[team_id] ||= { count: 0, size: 0 }
        teams[team_id][:count] += 1
        teams[team_id][:size] += object.size
      end

      size_mb = (object.size / 1024.0 / 1024.0).round(2)
      puts "  #{object.key} (#{size_mb} MB)"
    end

    if teams.any?
      puts "\n📊 Summary by Team:"
      teams.each do |team_id, data|
        size_mb = (data[:size] / 1024.0 / 1024.0).round(2)
        puts "   Team #{team_id}: #{data[:count]} files, #{size_mb} MB"
      end
    end

    total_size_mb = (total_size / 1024.0 / 1024.0).round(2)
    puts "\n📊 Total: #{file_count} files, #{total_size_mb} MB"
  end

  def cleanup(environment = 'development', team_id = nil)
    unless environment == 'development'
      puts '❌ For safety, this script only cleans development environment!'
      puts '   To clean other environments, use the Rails rake tasks.'
      exit 1
    end

    prefix = team_id ? "#{environment}/team-#{team_id}/" : "#{environment}/"

    puts "\n⚠️  WARNING: This will DELETE all files from S3!"
    puts "   Path: s3://#{@bucket}/#{prefix}"
    print "\nType 'DELETE' to confirm: "

    confirmation = gets.chomp
    unless confirmation == 'DELETE'
      puts 'Cancelled.'
      exit 0
    end

    objects_to_delete = []

    list_objects(prefix) do |object|
      objects_to_delete << { key: object.key }
      puts "  Marking for deletion: #{object.key}"
    end

    if objects_to_delete.empty?
      puts "\n✅ No files found to delete."
    else
      puts "\n🗑️  Deleting #{objects_to_delete.size} files..."

      # Delete in batches of 1000 (S3 limit)
      objects_to_delete.each_slice(1000) do |batch|
        @s3_client.delete_objects(
          bucket: @bucket,
          delete: {
            objects: batch,
            quiet: false
          }
        )
      end

      puts "✅ Successfully deleted #{objects_to_delete.size} files."
    end
  rescue Aws::S3::Errors::ServiceError => e
    puts "❌ S3 Error: #{e.message}"
    exit 1
  end

  def cleanup_orphaned_files
    puts "\n🔍 Searching for orphaned files (files without database records)..."
    puts '   This feature requires Rails environment. Use: rails s3:cleanup:orphaned'
    puts '   Not available in standalone script.'
  end

  private

  def list_objects(prefix, &block)
    continuation_token = nil

    loop do
      response = @s3_client.list_objects_v2(
        bucket: @bucket,
        prefix: prefix,
        continuation_token: continuation_token
      )

      response.contents.each(&block)

      break unless response.is_truncated

      continuation_token = response.next_continuation_token
    end
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  unless ENV.fetch('S3_BUCKET', nil) && ENV.fetch('AWS_ACCESS_KEY_ID', nil) && ENV['AWS_SECRET_ACCESS_KEY']
    puts '❌ Missing AWS credentials!'
    puts '   Please ensure your .env file contains:'
    puts '   - S3_BUCKET'
    puts '   - AWS_ACCESS_KEY_ID'
    puts '   - AWS_SECRET_ACCESS_KEY'
    puts '   - AWS_REGION (optional, defaults to us-east-1)'
    exit 1
  end

  cleaner = S3Cleanup.new
  command = ARGV[0]

  case command
  when 'list'
    cleaner.list_files('development', ARGV[1])
  when 'development'
    cleaner.cleanup('development', ARGV[1])
  when 'help', '--help', '-h', nil
    puts "\n📚 S3 Cleanup Helper"
    puts "\nUsage:"
    puts '  ruby scripts/s3_cleanup.rb list                    # List all development files'
    puts '  ruby scripts/s3_cleanup.rb list [team_id]          # List files for specific team'
    puts '  ruby scripts/s3_cleanup.rb development             # Delete ALL development files'
    puts '  ruby scripts/s3_cleanup.rb development [team_id]   # Delete specific team files'
    puts '  ruby scripts/s3_cleanup.rb help                    # Show this help'
    puts "\n⚠️  WARNING: Delete operations are DESTRUCTIVE and cannot be undone!"
    puts "\nFor production cleanup, use Rails rake tasks with additional safeguards."
  else
    puts "❌ Unknown command: #{command}"
    puts "   Use 'ruby scripts/s3_cleanup.rb help' for usage information."
    exit 1
  end
end
