# frozen_string_literal: true

# S3 cleanup tasks
namespace :s3 do
  namespace :cleanup do
    desc 'Clean all development environment files from S3 (DESTRUCTIVE!)'
    task development: :environment do
      unless Rails.env.development?
        puts '❌ This task can only be run in development environment!'
        exit 1
      end

      puts "\n⚠️  WARNING: This will DELETE all development files from S3!"
      puts "   Path: s3://#{ENV.fetch('S3_BUCKET', nil)}/development/"
      print "\nType 'DELETE' to confirm: "

      confirmation = $stdin.gets.chomp
      unless confirmation == 'DELETE'
        puts 'Cancelled.'
        exit 0
      end

      require 'aws-sdk-s3'

      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'] || 'us-east-1',
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
      )

      bucket = ENV.fetch('S3_BUCKET', nil)
      prefix = 'development/'

      begin
        # List all objects with the prefix
        objects_to_delete = []
        continuation_token = nil

        loop do
          response = s3_client.list_objects_v2(
            bucket: bucket,
            prefix: prefix,
            continuation_token: continuation_token
          )

          response.contents.each do |object|
            objects_to_delete << { key: object.key }
            puts "  Found: #{object.key}"
          end

          break unless response.is_truncated

          continuation_token = response.next_continuation_token
        end

        if objects_to_delete.empty?
          puts "\n✅ No files found to delete."
        else
          puts "\n🗑️  Deleting #{objects_to_delete.size} files..."

          # Delete in batches of 1000 (S3 limit)
          objects_to_delete.each_slice(1000) do |batch|
            s3_client.delete_objects(
              bucket: bucket,
              delete: {
                objects: batch,
                quiet: false
              }
            )
          end

          puts "✅ Successfully deleted #{objects_to_delete.size} files from S3 development environment."
        end
      rescue Aws::S3::Errors::ServiceError => e
        puts "❌ S3 Error: #{e.message}"
        exit 1
      end
    end

    desc 'Clean specific team files from S3 development environment'
    task :team, [:team_id] => :environment do |_t, args|
      unless Rails.env.development?
        puts '❌ This task can only be run in development environment!'
        exit 1
      end

      unless args[:team_id]
        puts '❌ Please provide a team_id: rails s3:cleanup:team[123]'
        exit 1
      end

      team_id = args[:team_id]

      puts "\n⚠️  WARNING: This will DELETE all files for team #{team_id} from S3 development!"
      puts "   Path: s3://#{ENV.fetch('S3_BUCKET', nil)}/development/team-#{team_id}/"
      print "\nType 'DELETE' to confirm: "

      confirmation = $stdin.gets.chomp
      unless confirmation == 'DELETE'
        puts 'Cancelled.'
        exit 0
      end

      require 'aws-sdk-s3'

      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'] || 'us-east-1',
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
      )

      bucket = ENV.fetch('S3_BUCKET', nil)
      prefix = "development/team-#{team_id}/"

      begin
        # List all objects with the prefix
        objects_to_delete = []
        continuation_token = nil

        loop do
          response = s3_client.list_objects_v2(
            bucket: bucket,
            prefix: prefix,
            continuation_token: continuation_token
          )

          response.contents.each do |object|
            objects_to_delete << { key: object.key }
            puts "  Found: #{object.key}"
          end

          break unless response.is_truncated

          continuation_token = response.next_continuation_token
        end

        if objects_to_delete.empty?
          puts "\n✅ No files found to delete for team #{team_id}."
        else
          puts "\n🗑️  Deleting #{objects_to_delete.size} files..."

          # Delete in batches of 1000 (S3 limit)
          objects_to_delete.each_slice(1000) do |batch|
            s3_client.delete_objects(
              bucket: bucket,
              delete: {
                objects: batch,
                quiet: false
              }
            )
          end

          puts "✅ Successfully deleted #{objects_to_delete.size} files for team #{team_id}."
        end
      rescue Aws::S3::Errors::ServiceError => e
        puts "❌ S3 Error: #{e.message}"
        exit 1
      end
    end

    desc 'List all files in S3 development environment'
    task list: :environment do
      require 'aws-sdk-s3'

      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'] || 'us-east-1',
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
      )

      bucket = ENV.fetch('S3_BUCKET', nil)
      prefix = 'development/'

      begin
        puts "\n📂 Files in S3 development environment:"
        puts "   Bucket: s3://#{bucket}/#{prefix}\n\n"

        file_count = 0
        total_size = 0
        continuation_token = nil

        loop do
          response = s3_client.list_objects_v2(
            bucket: bucket,
            prefix: prefix,
            continuation_token: continuation_token
          )

          response.contents.each do |object|
            file_count += 1
            total_size += object.size
            size_mb = (object.size / 1024.0 / 1024.0).round(2)
            puts "  #{object.key} (#{size_mb} MB)"
          end

          break unless response.is_truncated

          continuation_token = response.next_continuation_token
        end

        total_size_mb = (total_size / 1024.0 / 1024.0).round(2)
        puts "\n📊 Total: #{file_count} files, #{total_size_mb} MB"
      rescue Aws::S3::Errors::ServiceError => e
        puts "❌ S3 Error: #{e.message}"
        exit 1
      end
    end
  end
end

# Hook setup removed - was causing task loading issues
