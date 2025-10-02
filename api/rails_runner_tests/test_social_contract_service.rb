#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for SocialContractServiceSociety
# Usage: rails runner rails_runner_tests/test_social_contract_service.rb

puts "="*60
puts "Testing SocialContractServiceSociety with Office #6"
puts "="*60

# Find office
office = Office.find(6)
puts "\nOffice Information:"
puts "  ID: #{office.id}"
puts "  Name: #{office.name}"
puts "  CNPJ: #{office.cnpj}"
puts "  Society: #{office.society}"
puts "  Accounting Type: #{office.accounting_type}"
puts "  Quote Value: #{office.quote_value}"
puts "  Number of Quotes: #{office.number_of_quotes}"

# Initialize the service with office_id
service = DocxServices::SocialContractServiceSociety.new(office.id)

puts "\nFormatter Information:"
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

# Check if template exists
template_path = Rails.root.join('app', 'services', 'docx_services', 'templates', 'CS-TEMPLATE.docx')
template_found = File.exist?(template_path)

if template_found
  puts "\n✓ Template found at: #{template_path}"
else
  puts "\n✗ Template file not found at: #{template_path}"
  puts "  Please ensure the template exists at the correct location."
end

# Process the document if template exists
if template_found
  begin
    puts "\n"*2
    puts "="*60
    puts "Processing Document..."
    puts "="*60
    
    file_path = service.call
    
    puts "✓ Document processed successfully!"
    puts "  Generated file: #{file_path}"
    puts "  File exists: #{File.exist?(file_path)}"
    
    if File.exist?(file_path)
      puts "  File size: #{File.size(file_path)} bytes"
      puts "  File location: #{file_path}"
    end
    
  rescue => e
    puts "\n✗ Error processing document:"
    puts "  #{e.class}: #{e.message}"
    puts "\nBacktrace:"
    puts e.backtrace.first(10).join("\n")
  end
else
  puts "\n⚠️  Skipping document processing due to missing template"
end

puts "\n"*2
puts "="*60
puts "Test completed!"
puts "="*60