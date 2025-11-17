namespace :s3 do
  desc "Remove all old storage systems and implement new"
  task clean_slate: :environment do
    puts "Starting clean slate process..."
    puts "WARNING: This will remove all ActiveStorage and old S3 implementations!"
    puts "Continue? (y/N)"

    input = STDIN.gets.chomp
    unless input.downcase == 'y'
      puts "Aborted."
      exit
    end

    puts "\n1. Dropping ActiveStorage tables..."
    begin
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_blobs CASCADE")
      puts "   ✓ Dropped active_storage_blobs"
    rescue => e
      puts "   ✗ Error dropping active_storage_blobs: #{e.message}"
    end

    begin
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_attachments CASCADE")
      puts "   ✓ Dropped active_storage_attachments"
    rescue => e
      puts "   ✗ Error dropping active_storage_attachments: #{e.message}"
    end

    begin
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_variant_records CASCADE")
      puts "   ✓ Dropped active_storage_variant_records"
    rescue => e
      puts "   ✗ Error dropping active_storage_variant_records: #{e.message}"
    end

    puts "\n2. Dropping old metadata tables..."
    begin
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS office_attachment_metadata CASCADE")
      puts "   ✓ Dropped office_attachment_metadata"
    rescue => e
      puts "   ✗ Error dropping office_attachment_metadata: #{e.message}"
    end

    puts "\nClean slate complete! Ready for new S3Manager implementation."
    puts "\nNext steps:"
    puts "1. Run migrations: rails db:migrate"
    puts "2. Remove old columns: rails s3:remove_old_columns"
  end

  desc "Remove old S3 key columns"
  task remove_old_columns: :environment do
    puts "Removing old S3 key columns..."

    # Office table
    if ActiveRecord::Base.connection.column_exists?(:offices, :logo_s3_key)
      ActiveRecord::Migration.remove_column :offices, :logo_s3_key
      puts "   ✓ Removed logo_s3_key from offices"
    end

    # UserProfile table
    if ActiveRecord::Base.connection.column_exists?(:user_profiles, :avatar_s3_key)
      ActiveRecord::Migration.remove_column :user_profiles, :avatar_s3_key
      puts "   ✓ Removed avatar_s3_key from user_profiles"
    end

    # Document table
    if ActiveRecord::Base.connection.column_exists?(:documents, :original_s3_key)
      ActiveRecord::Migration.remove_column :documents, :original_s3_key
      puts "   ✓ Removed original_s3_key from documents"
    end

    if ActiveRecord::Base.connection.column_exists?(:documents, :signed_s3_key)
      ActiveRecord::Migration.remove_column :documents, :signed_s3_key
      puts "   ✓ Removed signed_s3_key from documents"
    end

    # CustomerFile table
    if ActiveRecord::Base.connection.column_exists?(:customer_files, :file_s3_key)
      ActiveRecord::Migration.remove_column :customer_files, :file_s3_key
      puts "   ✓ Removed file_s3_key from customer_files"
    end

    # Job table
    if ActiveRecord::Base.connection.column_exists?(:jobs, :attachment_s3_key)
      ActiveRecord::Migration.remove_column :jobs, :attachment_s3_key
      puts "   ✓ Removed attachment_s3_key from jobs"
    end

    # Work table - check for any document-related s3 columns
    if ActiveRecord::Base.connection.column_exists?(:works, :document_s3_keys)
      ActiveRecord::Migration.remove_column :works, :document_s3_keys
      puts "   ✓ Removed document_s3_keys from works"
    end

    puts "\nOld columns removed successfully!"
  end

  desc "Verify new S3 system setup"
  task verify_setup: :environment do
    puts "Verifying new S3 system setup..."

    errors = []

    # Check FileMetadata table
    if ActiveRecord::Base.connection.table_exists?(:file_metadata)
      puts "   ✓ FileMetadata table exists"
    else
      errors << "FileMetadata table does not exist"
      puts "   ✗ FileMetadata table does not exist"
    end

    # Check TempUpload table
    if ActiveRecord::Base.connection.table_exists?(:temp_uploads)
      puts "   ✓ TempUploads table exists"
    else
      errors << "TempUploads table does not exist"
      puts "   ✗ TempUploads table does not exist"
    end

    # Check models exist
    begin
      FileMetadata
      puts "   ✓ FileMetadata model loaded"
    rescue NameError
      errors << "FileMetadata model not found"
      puts "   ✗ FileMetadata model not found"
    end

    begin
      TempUpload
      puts "   ✓ TempUpload model loaded"
    rescue NameError
      errors << "TempUpload model not found"
      puts "   ✗ TempUpload model not found"
    end

    # Check services exist
    begin
      S3Manager
      puts "   ✓ S3Manager service loaded"
    rescue NameError
      errors << "S3Manager service not found"
      puts "   ✗ S3Manager service not found"
    end

    begin
      PathGenerator
      puts "   ✓ PathGenerator module loaded"
    rescue NameError
      errors << "PathGenerator module not found"
      puts "   ✗ PathGenerator module not found"
    end

    # Check environment variables
    required_env_vars = %w[AWS_BUCKET_MAIN AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY]
    required_env_vars.each do |var|
      if ENV[var].present?
        puts "   ✓ #{var} is set"
      else
        errors << "#{var} environment variable not set"
        puts "   ✗ #{var} is not set"
      end
    end

    if errors.empty?
      puts "\n✅ All checks passed! S3 system is ready."
    else
      puts "\n❌ Setup incomplete. Please fix the following issues:"
      errors.each { |error| puts "   - #{error}" }
    end
  end
end