#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for Social Contract integration in Office creation
# Usage: rails runner rails_runner_tests/test_social_contract_integration.rb

puts "="*80
puts "Testing Social Contract Generation Integration"
puts "="*80

# Helper method to generate valid CNPJ
def generate_valid_cnpj
  # Generate 12 random digits
  base = Array.new(8) { rand(0..9) } + [0, 0, 0, 1]

  # Calculate first check digit
  weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  sum1 = base.each_with_index.sum { |digit, index| digit * weights1[index] }
  remainder1 = sum1 % 11
  check1 = remainder1 < 2 ? 0 : 11 - remainder1
  base << check1

  # Calculate second check digit
  weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  sum2 = base.each_with_index.sum { |digit, index| digit * weights2[index] }
  remainder2 = sum2 % 11
  check2 = remainder2 < 2 ? 0 : 11 - remainder2
  base << check2

  # Format as string
  cnpj = base.join
  "#{cnpj[0..1]}.#{cnpj[2..4]}.#{cnpj[5..7]}/#{cnpj[8..11]}-#{cnpj[12..13]}"
end

# Helper method to simulate office creation with contract generation
def test_office_creation_with_contract(office_params, user_offices_data, description)
  puts "\n" + "="*60
  puts description
  puts "="*60

  begin
    # Get the first admin user or create one for testing
    timestamp = Time.now.to_i
    user = User.first || User.create!(
      email: "test_#{timestamp}@example.com",
      password: 'password123',
      team: Team.first || Team.create!(name: 'Test Team')
    )

    team = user.team

    # Build office with the flag for social contract generation
    office_attrs = office_params.merge(
      team_id: team.id,
      created_by_id: user.id,
      create_social_contract: true # This triggers the generation
    )

    office = Office.new(office_attrs)

    # Add user_offices for partners/lawyers
    user_offices_data.each do |user_office_data|
      test_user = User.find_by(id: user_office_data[:user_id]) || User.create!(
        email: "user#{user_office_data[:user_id]}_#{timestamp}@test.com",
        password: 'password123',
        team: team
      )

      # Create UserProfile with lawyer role
      UserProfile.find_or_create_by!(
        user_id: test_user.id,
        office_id: nil # Will be updated after save
      ) do |profile|
        profile.role = 'lawyer'
        profile.name = "Test User #{user_office_data[:user_id]}"
        profile.oab = "OAB/SP #{100000 + user_office_data[:user_id]}"
        profile.cpf = "#{111 + user_office_data[:user_id]}.222.333-44"
      end

      office.user_offices.build(
        user_id: test_user.id,
        partnership_type: user_office_data[:partnership_type],
        partnership_percentage: user_office_data[:partnership_percentage],
        is_administrator: user_office_data[:is_administrator],
        entry_date: user_office_data[:entry_date] || Date.current
      )
    end

    if office.save
      # Update user profiles with office_id
      office.users.each do |u|
        profile = UserProfile.find_by(user_id: u.id)
        profile.update!(office_id: office.id) if profile
      end

      puts "✓ Office created successfully: #{office.name} (ID: #{office.id})"

      # Simulate the controller logic for contract generation
      puts "\n📄 Attempting to generate social contract..."

      # Check lawyer count
      lawyers_count = office.user_profiles.where(role: 'lawyer').count
      puts "  Lawyers count: #{lawyers_count}"
      puts "  Expected service: #{lawyers_count == 1 ? 'Unipessoal' : 'Society'}"

      # Call the service directly (simulating what controller would do)
      service = DocxServices::SocialContractServiceFacade.new(office.id)
      puts "  Service routed to: #{service.service.class.name}"

      file_path = service.call

      if File.exist?(file_path)
        puts "✓ Social contract generated successfully!"
        puts "  File path: #{file_path}"
        puts "  File size: #{File.size(file_path)} bytes"
        puts "  File name: #{File.basename(file_path)}"

        # Test the upload process
        File.open(file_path, 'rb') do |file|
          # Create a wrapper that mimics ActionDispatch::Http::UploadedFile
          uploaded_file = Struct.new(:original_filename, :content_type, :size) do
            attr_accessor :file

            def initialize(file, filename)
              @file = file
              super(filename, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', file.size)
            end

            def read(*args)
              @file.read(*args)
            end

            def rewind
              @file.rewind
            end

            def size
              @file.size
            end
          end.new(file, File.basename(file_path))

          metadata_params = {
            uploaded_by_id: user.id,
            document_date: Date.current,
            description: "Contrato Social gerado automaticamente para #{office.name}"
          }

          if office.upload_social_contract(uploaded_file, metadata_params)
            puts "✓ Social contract uploaded to S3 successfully!"

            # Verify attachment metadata
            contract_metadata = office.attachment_metadata.where(document_type: 'social_contract').last
            if contract_metadata
              puts "  Metadata ID: #{contract_metadata.id}"
              puts "  S3 Key: #{contract_metadata.s3_key}"
              puts "  Filename: #{contract_metadata.filename}"
            end
          else
            puts "✗ Failed to upload social contract to S3"
            puts "  Errors: #{office.errors.full_messages}"
          end
        end

      else
        puts "✗ Social contract file not generated"
      end

      # Clean up the generated file
      File.delete(file_path) if File.exist?(file_path)

    else
      puts "✗ Office creation failed:"
      office.errors.full_messages.each { |error| puts "  - #{error}" }
    end

  rescue => e
    puts "✗ Error during test: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
end

# Test Case 1: Society (Multiple Lawyers)
puts "\n🧪 TEST CASE 1: Society Office with Multiple Lawyers"
test_office_creation_with_contract(
  {
    name: "Test Law Firm Society #{Time.now.to_i}",
    cnpj: generate_valid_cnpj,
    society: 'company',
    accounting_type: 'simple',
    quote_value: 50000.00,
    number_of_quotes: 2000,
    proportional: false
  },
  [
    {
      user_id: 1,
      partnership_type: 'socio',
      partnership_percentage: 60.0,
      is_administrator: true
    },
    {
      user_id: 2,
      partnership_type: 'socio',
      partnership_percentage: 40.0,
      is_administrator: false
    }
  ],
  "Creating Society Office with 2 partners"
)

# Test Case 2: Unipessoal (Single Lawyer)
puts "\n🧪 TEST CASE 2: Unipessoal Office with Single Lawyer"
test_office_creation_with_contract(
  {
    name: "Test Individual Law Firm #{Time.now.to_i}",
    cnpj: generate_valid_cnpj,
    society: 'individual',
    accounting_type: 'simple',
    quote_value: 25000.00,
    number_of_quotes: 1000,
    proportional: true
  },
  [
    {
      user_id: 3,
      partnership_type: 'socio',
      partnership_percentage: 100.0,
      is_administrator: true
    }
  ],
  "Creating Unipessoal Office with 1 lawyer"
)

puts "\n" + "="*80
puts "Integration Test Completed!"
puts "="*80
puts "\n📋 Summary:"
puts "- Society office contract generation: Tested"
puts "- Unipessoal office contract generation: Tested"
puts "- S3 upload integration: Tested"
puts "- Metadata creation: Tested"
puts "\n💡 Note: Check the output directory for generated files:"
puts "  app/services/docx_services/output/"