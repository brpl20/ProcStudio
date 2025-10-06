#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for SocialContractServiceUnipessoal
# Usage: rails runner rails_runner_tests/test_social_contract_service_unipessoal.rb

puts "="*60
puts "Testing SocialContractServiceUnipessoal with Office #37"
puts "="*60

# Find office (individual society with single lawyer)
office = Office.find_by(id: 37)

if office.nil?
  puts "\n✗ Office #37 not found! Please check if the office exists."
  exit 1
end

puts "\nOffice Information:"
puts "  ID: #{office.id}"
puts "  Name: #{office.name}"
puts "  CNPJ: #{office.cnpj}"
puts "  Society: #{office.society}"
puts "  Accounting Type: #{office.accounting_type}"
puts "  Quote Value: #{office.quote_value}"
puts "  Number of Quotes: #{office.number_of_quotes}"
puts "  Proportional: #{office.proportional}"

# Check lawyer count
lawyers_count = office.user_profiles.where(role: 'lawyer').count
puts "  Lawyers count: #{lawyers_count}"

if lawyers_count != 1
  puts "\n⚠️  Warning: This office has #{lawyers_count} lawyers, expected 1 for Unipessoal service"
end

# Test facade routing
puts "\n" + "="*60
puts "Testing Facade Routing"
puts "="*60

facade = DocxServices::SocialContractServiceFacade.new(office.id)
puts "Facade routed to: #{facade.service.class.name}"
puts "Expected: DocxServices::SocialContractServiceUnipessoal"

if facade.service.is_a?(DocxServices::SocialContractServiceUnipessoal)
  puts "✓ Correct routing to Unipessoal service"
else
  puts "✗ Incorrect routing - expected Unipessoal service"
end

# Initialize the service directly
begin
  service = DocxServices::SocialContractServiceUnipessoal.new(office.id)
  puts "\n✓ SocialContractServiceUnipessoal initialized successfully"
rescue => e
  puts "\n✗ Error initializing SocialContractServiceUnipessoal:"
  puts "  #{e.class}: #{e.message}"
  exit 1
end

puts "\nFormatter Information:"
puts "  Office Formatter:"
puts "    - Society Type: #{service.formatter_office.society}"
puts "    - Accounting Type: #{service.formatter_office.accounting_type}"
puts "    - Quote Value: #{service.formatter_office.quote_value}"
puts "    - Quote Value (extenso): #{service.formatter_office.quote_value(extenso: true)}"
puts "    - Number of Quotes: #{service.formatter_office.number_of_quotes}"
puts "    - OAB Status: #{service.formatter_office.oab_status}"
puts "    - OAB ID: #{service.formatter_office.oab_id}"
puts "    - Is Proportional: #{service.formatter_office.is_proportional}"

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
  puts "      - Partner Quote Value: #{partner_info[:partner_quote_value_formatted] || 'N/A'}"
  puts "      - Partner Number of Quotes: #{partner_info[:partner_number_of_quotes_formatted] || 'N/A'}"
end

puts "\n  Partner Compensation:"
service.formatter_office.partners_compensation.each do |comp_info|
  puts "    Partner #{comp_info[:number]}:"
  puts "      - Name: #{comp_info[:lawyer_name]}"
  puts "      - Compensation Type: #{comp_info[:compensation_type] || 'None'}"
  puts "      - Compensation Amount: #{comp_info[:compensation_amount_formatted] || 'None'}"
  puts "      - Payment Frequency: #{comp_info[:payment_frequency] || 'None'}"
end

# Check if template exists
template_path = Rails.root.join('app', 'services', 'docx_services', 'templates', 'CS-UNIPESSOAL-TEMPLATE.docx')
template_found = File.exist?(template_path)

if template_found
  puts "\n✓ Unipessoal template found at: #{template_path}"
else
  puts "\n✗ Unipessoal template file not found at: #{template_path}"
  puts "  Please ensure the CS-UNIPESSOAL-TEMPLATE.docx exists at the correct location."
  
  # Check if regular template exists as reference
  regular_template = Rails.root.join('app', 'services', 'docx_services', 'templates', 'CS-TEMPLATE.docx')
  if File.exist?(regular_template)
    puts "  ℹ️  Regular template found at: #{regular_template}"
    puts "  The Unipessoal template should be specifically designed for single-lawyer offices"
  end
end

# Test facade document processing
puts "\n"*2
puts "="*60
puts "Testing Facade Document Processing..."
puts "="*60

begin
  file_path = facade.call
  
  puts "✓ Document processed successfully via facade!"
  puts "  Generated file: #{file_path}"
  puts "  File exists: #{File.exist?(file_path)}"
  
  if File.exist?(file_path)
    puts "  File size: #{File.size(file_path)} bytes"
    puts "  File location: #{file_path}"
  end
  
rescue => e
  puts "\n✗ Error processing document via facade:"
  puts "  #{e.class}: #{e.message}"
  puts "\nBacktrace:"
  puts e.backtrace.first(10).join("\n")
end

puts "\n"*2
puts "="*60
puts "Test completed!"
puts "="*60