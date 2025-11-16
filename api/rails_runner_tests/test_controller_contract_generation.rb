#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for testing controller's social contract generation
# Usage: rails runner rails_runner_tests/test_controller_contract_generation.rb

require 'ostruct'

puts "="*80
puts "Testing Controller Social Contract Generation Method"
puts "="*80

class MockController
  attr_accessor :office, :current_user

  def initialize(office, user)
    @office = office
    @current_user = user
  end

  # Copy of the actual controller methods for testing
  def process_social_contract_generation
    Rails.logger.info "Social contract generation requested for office #{@office.id}"

    begin
      # Generate the social contract document using the facade service
      service = DocxServices::SocialContractServiceFacade.new(@office.id)
      file_path = service.call

      # Create a file-like object from the generated document
      File.open(file_path, 'rb') do |file|
        # Create a wrapper object that mimics an uploaded file
        uploaded_file = ContractFileWrapper.new(file, file_path)

        metadata_params = {
          uploaded_by_id: current_user.id,
          document_date: Date.current,
          description: "Contrato Social gerado automaticamente para #{@office.name}"
        }

        if @office.upload_social_contract(uploaded_file, metadata_params)
          Rails.logger.info "Social contract generated and uploaded successfully for office #{@office.id}"
          Rails.logger.info "Generated file path: #{file_path}"
        else
          Rails.logger.error "Failed to upload generated social contract for office #{@office.id}"
          Rails.logger.error "Office errors: #{@office.errors.full_messages}"
        end
      end

      # Optionally, clean up the temporary file after successful upload
      File.delete(file_path) if File.exist?(file_path) && Rails.env.production?

    rescue StandardError => e
      Rails.logger.error "Social contract generation failed for office #{@office.id}: #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      # Not failing the entire office creation if contract generation fails
      # You might want to add this error to a notification system or queue for retry
    end
  end

  def should_generate_social_contract?
    return false unless @office.create_social_contract.present?

    # Handle both string and boolean values
    case @office.create_social_contract
    when true, 'true', 'TRUE', 'True', '1', 1
      true
    else
      false
    end
  end

  # Wrapper class to make a File object compatible with S3 upload expectations
  class ContractFileWrapper
    attr_reader :original_filename, :content_type

    def initialize(file, file_path)
      @file = file
      @original_filename = File.basename(file_path)
      @content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    end

    def read(*args)
      @file.read(*args)
    end

    def size
      @file.size
    end

    def rewind
      @file.rewind
    end

    def close
      @file.close
    end
  end
end

# Test the controller method
def test_controller_generation(create_social_contract_value, expected_result)
  puts "\n" + "-"*60
  puts "Testing with create_social_contract = #{create_social_contract_value.inspect}"
  puts "-"*60

  begin
    # Setup test data
    user = User.first || User.create!(
      email: 'controller_test@example.com',
      password: 'password123',
      team: Team.first || Team.create!(name: 'Test Team')
    )

    team = user.team

    # Find or create a test office with the appropriate flag
    office = Office.find_by(id: 42) # Use existing office if available

    if office
      puts "Using existing office: #{office.name} (ID: #{office.id})"
    else
      puts "Creating new test office..."
      office = Office.create!(
        name: "Controller Test Office #{Time.now.to_i}",
        cnpj: "33.444.555/0001-#{rand(10..99)}",
        society: 'company',
        accounting_type: 'simple',
        quote_value: 30000.00,
        number_of_quotes: 1500,
        team_id: team.id
      )

      # Add some user_offices
      2.times do |i|
        test_user = User.create!(
          email: "ctrl_test_user#{i}@test.com",
          password: 'password123',
          team: team
        )

        UserProfile.create!(
          user_id: test_user.id,
          office_id: office.id,
          role: 'lawyer'
        )

        office.user_offices.create!(
          user_id: test_user.id,
          partnership_type: 'socio',
          partnership_percentage: i == 0 ? 60.0 : 40.0,
          is_administrator: i == 0
        )
      end
    end

    # Set the create_social_contract flag
    office.create_social_contract = create_social_contract_value

    # Create mock controller
    controller = MockController.new(office, user)

    # Test should_generate_social_contract?
    should_generate = controller.should_generate_social_contract?
    puts "should_generate_social_contract? = #{should_generate}"

    if should_generate != expected_result
      puts "✗ FAILED: Expected #{expected_result}, got #{should_generate}"
    else
      puts "✓ PASSED: Correctly returned #{should_generate}"
    end

    # If it should generate, test the actual generation
    if should_generate
      puts "\n📄 Testing contract generation..."

      # Count contracts before
      contracts_before = office.attachment_metadata.where(document_type: 'social_contract').count

      # Run the generation
      controller.process_social_contract_generation

      # Count contracts after
      contracts_after = office.attachment_metadata.where(document_type: 'social_contract').count

      if contracts_after > contracts_before
        puts "✓ Contract generated and uploaded successfully!"
        puts "  New contracts added: #{contracts_after - contracts_before}"

        latest_contract = office.attachment_metadata.where(document_type: 'social_contract').last
        if latest_contract
          puts "  Latest contract:"
          puts "    - Filename: #{latest_contract.filename}"
          puts "    - S3 Key: #{latest_contract.s3_key}"
          puts "    - Size: #{latest_contract.byte_size} bytes"
          puts "    - Uploaded at: #{latest_contract.created_at}"
        end
      else
        puts "⚠️  Contract generation may have failed (check logs above)"
      end
    end

  rescue => e
    puts "✗ Error during test: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
end

# Run tests with various input values
puts "\n🧪 Testing Various Input Values for create_social_contract"

test_cases = [
  [true, true],
  ['true', true],
  ['TRUE', true],
  ['True', true],
  ['1', true],
  [1, true],
  [false, false],
  ['false', false],
  ['FALSE', false],
  ['0', false],
  [0, false],
  [nil, false],
  ['', false]
]

test_cases.each do |value, expected|
  test_controller_generation(value, expected)
end

puts "\n" + "="*80
puts "Controller Integration Test Completed!"
puts "="*80
puts "\n📋 Test Results:"
puts "- Tested #{test_cases.length} different input values"
puts "- Verified boolean/string handling"
puts "- Tested actual contract generation when enabled"
puts "\n💡 Check Rails logs for detailed generation output"