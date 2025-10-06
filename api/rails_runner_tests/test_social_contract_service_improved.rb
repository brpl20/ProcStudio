#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for improved SocialContractServiceSociety with TableInsertable concern
# Usage: rails runner rails_runner_tests/test_social_contract_service_improved.rb

puts "="*80
puts "Testing IMPROVED SocialContractServiceSociety with TableInsertable"
puts "="*80

# Test configuration
OFFICE_ID = 6
OUTPUT_DIR = Rails.root.join('app', 'services', 'docx_services', 'output')

# Ensure output directory exists
FileUtils.mkdir_p(OUTPUT_DIR) unless Dir.exist?(OUTPUT_DIR)

puts "\n[SETUP] Loading improved service file..."
# The improved file redefines the same class, so we need to load it directly
load Rails.root.join('app', 'services', 'docx_services', 'social_contract_service_society_improved.rb')
load Rails.root.join('app', 'services', 'docx_services', 'concerns', 'table_insertable_improved.rb')

# Find office
office = Office.find(OFFICE_ID)
puts "\n[OFFICE INFORMATION]"
puts "  ID: #{office.id}"
puts "  Name: #{office.name}"
puts "  CNPJ: #{office.cnpj}"
puts "  Society: #{office.society}"
puts "  Accounting Type: #{office.accounting_type}"
puts "  Quote Value: #{office.quote_value}"
puts "  Number of Quotes: #{office.number_of_quotes}"
puts "  Partners Count: #{office.user_profiles.count}"

# Initialize the service
puts "\n[SERVICE INITIALIZATION]"
begin
  service = DocxServices::SocialContractServiceSociety.new(office.id)
  puts "✓ Service initialized successfully"
rescue => e
  puts "✗ Failed to initialize service: #{e.message}"
  exit 1
end

# Test formatter objects
puts "\n[FORMATTER VALIDATION]"
puts "  Office Formatter:"
puts "    - Society Type: #{service.formatter_office.society}"
puts "    - Accounting Type: #{service.formatter_office.accounting_type}"
puts "    - Quote Value: #{service.formatter_office.quote_value}"
puts "    - Quote Value (extenso): #{service.formatter_office.quote_value(extenso: true)}"
puts "    - Number of Quotes: #{service.formatter_office.number_of_quotes}"
puts "    - OAB Status: #{service.formatter_office.oab_status}"
puts "    - OAB ID: #{service.formatter_office.oab_id}"

puts "\n  Office Qualification Formatter:"
puts "    - Full Name: #{service.formatter_qualification.full_name}"
puts "    - CNPJ: #{service.formatter_qualification.cnpj}"
puts "    - State: #{service.formatter_qualification.state}"
puts "    - City: #{service.formatter_qualification.city}"
puts "    - Address: #{service.formatter_qualification.address(with_prefix: false)}"
puts "    - Zip Code: #{service.formatter_qualification.zip_code}"

puts "\n  Partners (#{service.user_formatters.count}):"
service.user_formatters.each_with_index do |formatter, index|
  puts "    Partner #{index + 1}:"
  puts "      - Full Name: #{formatter.full_name}"
  puts "      - CPF: #{formatter.cpf}"
  puts "      - Profession: #{formatter.profession}"
  puts "      - Nationality: #{formatter.nationality}"
  puts "      - Civil Status: #{formatter.civil_status}"
end

puts "\n  Partner Office Relationships:"
service.formatter_office.partners_info.each do |partner_info|
  puts "    Partner #{partner_info[:number]}:"
  puts "      - Partnership Type: #{partner_info[:partnership_type]}"
  puts "      - Partnership Percentage: #{partner_info[:partnership_percentage]}"
  puts "      - Is Administrator: #{partner_info[:is_administrator]}"
end

# Check template
template_path = Rails.root.join('app', 'services', 'docx_services', 'templates', 'CS-TEMPLATE.docx')
template_found = File.exist?(template_path)

puts "\n[TEMPLATE VALIDATION]"
if template_found
  puts "✓ Template found at: #{template_path}"
  puts "  File size: #{File.size(template_path)} bytes"
else
  puts "✗ Template file not found at: #{template_path}"
  puts "  Please ensure the template exists at the correct location."
end

# Test TableInsertable concern
puts "\n[TABLE INSERTABLE CONCERN TEST]"
if service.respond_to?(:multiple_partners?, true)
  puts "✓ TableInsertable concern included"
  puts "  Multiple partners?: #{service.send(:multiple_partners?)}"
  
  if service.send(:multiple_partners?)
    puts "  Will insert #{office.user_profiles.count - 1} additional rows for partners"
  else
    puts "  Single partner - no additional rows needed"
  end
else
  puts "✗ TableInsertable concern not properly included"
end

# Process the document if template exists
if template_found
  begin
    puts "\n"*2
    puts "="*80
    puts "[DOCUMENT PROCESSING]"
    puts "="*80
    
    # Track processing time
    start_time = Time.now
    
    # Process document
    file_path = service.call
    
    processing_time = (Time.now - start_time).round(2)
    
    puts "✓ Document processed successfully!"
    puts "  Processing time: #{processing_time} seconds"
    puts "  Generated file: #{file_path}"
    puts "  File exists: #{File.exist?(file_path)}"
    
    if File.exist?(file_path)
      file_size_kb = (File.size(file_path) / 1024.0).round(2)
      puts "  File size: #{file_size_kb} KB"
      puts "  File location: #{file_path}"
      
      # Validate DOCX structure
      puts "\n[DOCX VALIDATION]"
      begin
        validation_doc = ::Docx::Document.open(file_path.to_s)
        puts "✓ Valid DOCX structure"
        puts "  Tables count: #{validation_doc.tables.count}"
        puts "  Paragraphs count: #{validation_doc.paragraphs.count}"
        
        # Check first table for partner rows
        if validation_doc.tables.any?
          first_table = validation_doc.tables.first
          puts "  First table rows: #{first_table.rows.count}"
          
          # Check if rows were inserted for multiple partners
          if office.user_profiles.count > 1
            expected_rows = 1 + office.user_profiles.count  # Header + partner rows
            if first_table.rows.count >= expected_rows
              puts "✓ Table rows inserted correctly for #{office.user_profiles.count} partners"
            else
              puts "⚠ Expected at least #{expected_rows} rows but found #{first_table.rows.count}"
            end
          end
        end
      rescue => e
        puts "✗ Invalid DOCX structure: #{e.message}"
      end
    else
      puts "✗ Generated file does not exist!"
    end
    
  rescue => e
    puts "\n✗ Error processing document:"
    puts "  #{e.class}: #{e.message}"
    puts "\n[BACKTRACE]"
    puts e.backtrace.first(15).join("\n")
  end
else
  puts "\n⚠️  Skipping document processing due to missing template"
end

# Summary
puts "\n"*2
puts "="*80
puts "[TEST SUMMARY]"
puts "="*80
puts "Office: #{office.name} (ID: #{office.id})"
puts "Partners: #{office.user_profiles.count}"
puts "Service: DocxServices::SocialContractServiceSociety (Improved)"
puts "TableInsertable: #{service.class.ancestors.include?(DocxServices::Concerns::TableInsertable) ? 'Yes' : 'No'}"
puts "Test completed at: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
puts "="*80