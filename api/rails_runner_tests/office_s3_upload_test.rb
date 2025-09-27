# frozen_string_literal: true

require 'aws-sdk-s3'
require 'tempfile'
require 'securerandom'

# Load environment variables from .env file
require 'dotenv'
Dotenv.overload(Rails.root.join('.env'))

class OfficeS3UploadTest
  def self.run
    puts '=' * 60
    puts 'OFFICE S3 UPLOAD TEST'
    puts '=' * 60
    puts

    new.perform_tests
  end

  def perform_tests
    check_environment_vars
    test_s3_connectivity
    test_office_logo_upload
    test_social_contract_upload
    test_multiple_files_upload
    cleanup_test_data
    print_summary
  rescue StandardError => e
    puts "\n❌ FATAL ERROR: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end

  private

  attr_reader :test_office, :test_results, :test_files

  def initialize
    @test_results = []
    @test_files = []
    @test_office = nil
  end

  def check_environment_vars
    puts '1. Checking Environment Variables...'
    puts '-' * 60

    # Check for AWS_BUCKET_MAIN or AWS_BUCKET_MAIN
    bucket_var = ENV['AWS_BUCKET_MAIN'] || ENV.fetch('AWS_BUCKET_MAIN', nil)
    if bucket_var.blank?
      puts '   ❌ AWS_BUCKET_MAIN/AWS_BUCKET_MAIN: NOT SET'
    else
      ENV['AWS_BUCKET_MAIN'] = bucket_var unless ENV['AWS_BUCKET_MAIN'] # Set AWS_BUCKET_MAIN if not present
      puts "   ✅ AWS_BUCKET_MAIN: #{bucket_var.first(10)}..."
    end

    # Check for AWS_DEFAULT_REGION
    region_var = ENV.fetch('AWS_DEFAULT_REGION', nil)
    ENV['AWS_DEFAULT_REGION'] = region_var unless ENV['AWS_DEFAULT_REGION'] # Set AWS_DEFAULT_REGION if not present
    puts "   ✅ AWS_DEFAULT_REGION: #{region_var}"

    required_vars = ['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY']
    missing_vars = []

    required_vars.each do |var|
      value = ENV.fetch(var, nil)
      if value.present?
        masked_value = var.include?('SECRET') ? '*' * 8 : "#{value.first(10)}..."
        puts "   ✅ #{var}: #{masked_value}"
      else
        puts "   ❌ #{var}: NOT SET"
        missing_vars << var
      end
    end

    if missing_vars.any? || bucket_var.blank? || region_var.blank?
      missing_list = missing_vars.dup
      missing_list << 'AWS_BUCKET_MAIN/AWS_BUCKET_MAIN' if bucket_var.blank?
      missing_list << 'AWS_DEFAULT_REGION/AWS_DEFAULT_REGION' if region_var.blank?
      @test_results << { test: 'Environment Variables', status: 'FAILED', message: "Missing: #{missing_list.join(', ')}" }
      puts "\n⚠️  WARNING: Missing environment variables may cause upload failures"
    else
      @test_results << { test: 'Environment Variables', status: 'SUCCESS', message: 'All required variables present' }
    end

    puts
  end

  def test_s3_connectivity
    puts '2. Testing S3 Connectivity...'
    puts '-' * 60

    begin
      s3_client = Aws::S3::Client.new(
        region: ENV.fetch('AWS_DEFAULT_REGION', nil),
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
      )

      # Test bucket access
      bucket = ENV.fetch('AWS_BUCKET_MAIN', nil)
      s3_client.head_bucket(bucket: bucket)
      puts "   ✅ Connected to S3 bucket: #{bucket}"

      # Try to list a few objects to verify read permissions
      objects = s3_client.list_objects_v2(bucket: bucket, max_keys: 1)
      puts "   ✅ Can list objects in bucket (found #{objects.key_count} object(s) in test query)"

      @test_results << { test: 'S3 Connectivity', status: 'SUCCESS', message: "Connected to #{bucket}" }
    rescue Aws::S3::Errors::NoSuchBucket => e
      puts "   ❌ Bucket not found: #{e.message}"
      @test_results << { test: 'S3 Connectivity', status: 'FAILED', message: "Bucket not found: #{bucket}" }
    rescue Aws::S3::Errors::Forbidden => e
      puts "   ❌ Access forbidden: #{e.message}"
      @test_results << { test: 'S3 Connectivity', status: 'FAILED', message: 'Access forbidden - check IAM permissions' }
    rescue StandardError => e
      puts "   ❌ Connection failed: #{e.message}"
      @test_results << { test: 'S3 Connectivity', status: 'FAILED', message: e.message }
    end

    puts
  end

  def test_office_logo_upload
    puts '3. Testing Office Logo Upload...'
    puts '-' * 60

    begin
      # Create a test office
      setup_test_office

      # Create a test image file
      logo_file = create_test_image_file('test-logo.png')
      @test_files << logo_file

      puts "   📁 Created test logo file: #{File.basename(logo_file.path)} (#{File.size(logo_file.path)} bytes)"

      # Create a mock uploaded file object with binary mode
      logo_file.binmode # Ensure file is in binary mode
      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: logo_file,
        filename: 'test-logo.png',
        type: 'image/png'
      )

      # Test the upload_logo method
      metadata_params = {
        uploaded_by_id: 1,
        description: 'Test logo upload'
      }

      puts '   📤 Uploading logo to S3...'
      if @test_office.upload_logo(uploaded_file, metadata_params)
        puts '   ✅ Logo uploaded successfully'
        puts "   📍 S3 Key: #{@test_office.logo_s3_key}"

        # Verify the file exists in S3
        if verify_s3_file_exists(@test_office.logo_s3_key)
          puts '   ✅ Verified: File exists in S3'

          # Test URL generation
          url = @test_office.logo_url
          if url
            puts '   ✅ Generated presigned URL (expires in 1 hour)'
            puts "   🔗 URL: #{url[0..80]}..."
          else
            puts '   ⚠️  Could not generate presigned URL'
          end

          @test_results << { test: 'Logo Upload', status: 'SUCCESS', message: "Uploaded to #{@test_office.logo_s3_key}" }
        else
          puts '   ❌ File NOT found in S3'
          @test_results << { test: 'Logo Upload', status: 'FAILED', message: 'File not found in S3 after upload' }
        end
      else
        puts "   ❌ Logo upload failed: #{@test_office.errors.full_messages.join(', ')}"
        @test_results << { test: 'Logo Upload', status: 'FAILED', message: @test_office.errors.full_messages.join(', ') }
      end
    rescue StandardError => e
      puts "   ❌ Error during logo upload test: #{e.message}"
      @test_results << { test: 'Logo Upload', status: 'ERROR', message: e.message }
    end

    puts
  end

  def test_social_contract_upload
    puts '4. Testing Social Contract Upload...'
    puts '-' * 60

    begin
      setup_test_office unless @test_office

      # Create a test PDF file
      contract_file = create_test_pdf_file('test-contract.pdf')
      @test_files << contract_file

      puts "   📁 Created test contract file: #{File.basename(contract_file.path)} (#{File.size(contract_file.path)} bytes)"

      # Create a mock uploaded file object
      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: contract_file,
        filename: 'test-contract.pdf',
        type: 'application/pdf'
      )

      # Test the upload_social_contract method
      metadata_params = {
        uploaded_by_id: 1,
        document_date: Date.current,
        description: 'Test social contract upload'
      }

      puts '   📤 Uploading social contract to S3...'
      if @test_office.upload_social_contract(uploaded_file, metadata_params)
        puts '   ✅ Social contract uploaded successfully'

        # Get the contract metadata
        contract_metadata = @test_office.attachment_metadata.last
        if contract_metadata
          puts "   📍 S3 Key: #{contract_metadata.s3_key}"

          # Verify the file exists in S3
          if verify_s3_file_exists(contract_metadata.s3_key)
            puts '   ✅ Verified: File exists in S3'

            # Test URL generation
            url = @test_office.generate_s3_url(contract_metadata.s3_key)
            if url
              puts '   ✅ Generated presigned URL'

              # Test download URL generation
              download_url = @test_office.generate_s3_download_url(contract_metadata.s3_key, contract_metadata.filename)
              puts '   ✅ Generated download URL with Content-Disposition header' if download_url
            else
              puts '   ⚠️  Could not generate presigned URL'
            end

            @test_results << { test: 'Social Contract Upload', status: 'SUCCESS', message: "Uploaded to #{contract_metadata.s3_key}" }
          else
            puts '   ❌ File NOT found in S3'
            @test_results << { test: 'Social Contract Upload', status: 'FAILED', message: 'File not found in S3 after upload' }
          end
        else
          puts '   ❌ No metadata record created'
          @test_results << { test: 'Social Contract Upload', status: 'FAILED', message: 'No metadata record created' }
        end
      else
        puts "   ❌ Social contract upload failed: #{@test_office.errors.full_messages.join(', ')}"
        @test_results << { test: 'Social Contract Upload', status: 'FAILED', message: @test_office.errors.full_messages.join(', ') }
      end
    rescue StandardError => e
      puts "   ❌ Error during social contract upload test: #{e.message}"
      @test_results << { test: 'Social Contract Upload', status: 'ERROR', message: e.message }
    end

    puts
  end

  def test_multiple_files_upload
    puts '5. Testing Multiple Files Upload...'
    puts '-' * 60

    begin
      setup_test_office unless @test_office

      # Create multiple test files
      files = []
      3.times do |i|
        file = create_test_pdf_file("contract-#{i + 1}.pdf")
        @test_files << file
        files << ActionDispatch::Http::UploadedFile.new(
          tempfile: file,
          filename: "contract-#{i + 1}.pdf",
          type: 'application/pdf'
        )
      end

      puts "   📁 Created #{files.size} test files"

      success_count = 0
      files.each_with_index do |file, index|
        metadata_params = {
          uploaded_by_id: 1,
          document_date: Date.current,
          description: "Test contract #{index + 1}"
        }

        if @test_office.upload_social_contract(file, metadata_params)
          success_count += 1
          puts "   ✅ File #{index + 1} uploaded successfully"
        else
          puts "   ❌ File #{index + 1} upload failed"
        end
      end

      if success_count == files.size
        puts "   ✅ All #{files.size} files uploaded successfully"

        # Verify all contracts are in the database
        total_contracts = @test_office.attachment_metadata.where(document_type: 'social_contract').count
        puts "   📊 Total social contracts in database: #{total_contracts}"

        # Test retrieval of all contracts
        contracts_with_metadata = @test_office.social_contracts_with_metadata
        puts "   📋 Retrieved #{contracts_with_metadata.size} contracts with metadata"

        @test_results << { test: 'Multiple Files Upload', status: 'SUCCESS', message: "Uploaded #{success_count}/#{files.size} files" }
      else
        @test_results << { test: 'Multiple Files Upload', status: 'PARTIAL', message: "Uploaded #{success_count}/#{files.size} files" }
      end
    rescue StandardError => e
      puts "   ❌ Error during multiple files upload test: #{e.message}"
      @test_results << { test: 'Multiple Files Upload', status: 'ERROR', message: e.message }
    end

    puts
  end

  def cleanup_test_data
    puts '6. Cleaning Up Test Data...'
    puts '-' * 60

    begin
      # Clean up test files
      @test_files.each do |file|
        if file && File.exist?(file.path)
          File.delete(file.path)
          puts "   🗑️  Deleted local file: #{File.basename(file.path)}"
        end
      end

      # Clean up S3 files if office exists
      if @test_office
        # Delete logo from S3
        if @test_office.logo_s3_key.present? && !@test_office.logo_s3_key.start_with?('local/')
          delete_s3_file(@test_office.logo_s3_key)
        end

        # Delete social contracts from S3
        @test_office.attachment_metadata.each do |metadata|
          delete_s3_file(metadata.s3_key) if metadata.s3_key.present? && !metadata.s3_key.start_with?('local/')
        end

        # Delete the test office
        @test_office.destroy!
        puts "   🗑️  Deleted test office: #{@test_office.name}"
      end

      puts '   ✅ Cleanup completed'
    rescue StandardError => e
      puts "   ⚠️  Cleanup error: #{e.message}"
    end

    puts
  end

  def print_summary
    puts '=' * 60
    puts 'TEST SUMMARY'
    puts '=' * 60
    puts

    @test_results.each do |result|
      status_icon = case result[:status]
                    when 'SUCCESS' then '✅'
                    when 'FAILED' then '❌'
                    when 'ERROR' then '🔥'
                    when 'PARTIAL' then '⚠️'
                    else '❓'
                    end

      puts "#{status_icon} #{result[:test]}: #{result[:status]}"
      puts "   └─ #{result[:message]}" if result[:message].present?
    end

    puts
    success_count = @test_results.count { |r| r[:status] == 'SUCCESS' }
    total_count = @test_results.size

    if success_count == total_count
      puts "🎉 All tests passed! (#{success_count}/#{total_count})"
    elsif success_count.positive?
      puts "⚠️  Some tests failed (#{success_count}/#{total_count} passed)"
    else
      puts "❌ All tests failed (0/#{total_count} passed)"
    end

    puts
    puts '=' * 60
  end

  # Helper methods

  def setup_test_office
    return if @test_office

    # Find or create a test team
    team = Team.first || Team.create!(name: 'Test Team')

    # Create a unique office name
    timestamp = Time.current.strftime('%Y%m%d%H%M%S')
    office_name = "Test Office #{timestamp}"

    @test_office = team.offices.create!(
      name: office_name,
      cnpj: generate_test_cnpj,
      society: 'company'
    )

    puts "   🏢 Created test office: #{@test_office.name} (ID: #{@test_office.id})"
  end

  def create_test_image_file(filename)
    file = Tempfile.new([filename.tr('.', '_'), '.png'])
    file.binmode # Ensure binary mode for image files

    # Create a simple PNG header (minimal valid PNG)
    png_header = [137, 80, 78, 71, 13, 10, 26, 10].pack('C*')
    ihdr_chunk = "#{[0, 0, 0, 13].pack('N')}IHDR#{[1, 1, 1, 0, 0, 0, 0].pack('NNCCCCC')}#{[55, 122, 183, 101].pack('N')}"
    iend_chunk = "#{[0, 0, 0, 0].pack('N')}IEND#{[174, 66, 96, 130].pack('N')}"

    file.write(png_header + ihdr_chunk + iend_chunk)
    file.rewind
    file
  end

  def create_test_pdf_file(filename)
    file = Tempfile.new([filename.tr('.', '_'), '.pdf'])

    # Create a minimal valid PDF
    pdf_content = <<~PDF
      %PDF-1.4
      1 0 obj
      << /Type /Catalog /Pages 2 0 R >>
      endobj
      2 0 obj
      << /Type /Pages /Kids [3 0 R] /Count 1 >>
      endobj
      3 0 obj
      << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>
      endobj
      xref
      0 4
      0000000000 65535 f
      0000000009 00000 n
      0000000058 00000 n
      0000000115 00000 n
      trailer
      << /Size 4 /Root 1 0 R >>
      startxref
      198
      %%EOF
    PDF

    file.write(pdf_content)
    file.rewind
    file
  end

  def generate_test_cnpj
    # Use the existing CNPJ generator from tests/helpers
    output = `node #{Rails.root}/../tests/helpers/cnpj_generator.js`
    cnpj = output.strip
    return cnpj if cnpj.present?

    # Fallback to a known valid CNPJ if the generator fails
    '11.222.333/0001-81'
  end

  def verify_s3_file_exists(s3_key)
    return false if s3_key.blank?
    return true if s3_key.start_with?('local/') # Local development mode

    s3_client = Aws::S3::Client.new(
      region: ENV.fetch('AWS_DEFAULT_REGION', nil),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    )

    s3_client.head_object(bucket: ENV.fetch('AWS_BUCKET_MAIN', nil), key: s3_key)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end

  def delete_s3_file(s3_key)
    return if s3_key.blank? || s3_key.start_with?('local/')

    s3_client = Aws::S3::Client.new(
      region: ENV.fetch('AWS_DEFAULT_REGION', nil),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    )

    s3_client.delete_object(bucket: ENV.fetch('AWS_BUCKET_MAIN', nil), key: s3_key)
    puts "   🗑️  Deleted S3 file: #{s3_key}"
  rescue StandardError => e
    puts "   ⚠️  Could not delete S3 file #{s3_key}: #{e.message}"
  end
end

# Run the test
OfficeS3UploadTest.run
