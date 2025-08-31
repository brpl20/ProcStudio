#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'docx'

# Define the template path and output path
template_path = '/Users/brpl/code/prc_api/docx/CS-TEMPLATE.docx'
output_path = '/Users/brpl/code/prc_api/docx/CS-OUTPUT.docx'
logo_path = '/Users/brpl/code/prc_api/docx/logo.png'

# Check if template exists
unless File.exist?(template_path)
  puts "Error: Template file not found at #{template_path}"
  exit 1
end

# Open the template document
puts "Opening template: #{template_path}"
doc = Docx::Document.open(template_path)

# Define mock data for replacements
mock_data = {
  'parner_total_quotes' => '15', # NOTE: keeping the typo from original
  'partner_full_name' => 'João Silva Santos',
  'partner_qualification' => 'Senior Partner - MBA, CPA',
  'partner_sum' => 'R$ 450.000,00',
  'percentage' => '35%',
  'society_address' => 'Rua das Empresas, 1234 - Sala 500',
  'society_city' => 'São Paulo',
  'society_name' => 'Sociedade Empresarial Exemplo Ltda.',
  'society_quote_value' => 'R$ 50.000,00',
  'society_quotes' => '1.250',
  'society_state' => 'SP',
  'society_total_value' => 'R$ 1.250.000,00',
  'society_zip_code' => '01310-100',
  'sum_percentage' => '100%',
  'total_quotes' => '2.500'
}

# First, replace all text fields
puts "\nReplacing text fields..."
doc.replace_fields(mock_data, '_', '_')
mock_data.each do |field, value|
  puts "  ✓ Replaced _#{field}_ with: #{value}"
end

# Handle logo replacement if logo file exists
if File.exist?(logo_path)
  puts "\nLooking for logo placeholder _society_logo_..."

  # Find and replace the logo placeholder
  logo_replaced = false
  doc.paragraphs.each_with_index do |paragraph, index|
    next unless paragraph.to_s.include?('_society_logo_')

    puts "  Found logo placeholder in paragraph #{index + 1}"

    # Clear the paragraph text
    paragraph.text = ''

    # Add the image to this paragraph
    # Using reasonable dimensions for a logo (adjust as needed)
    begin
      doc.add_image(logo_path, width: 200, height: 80)
      puts '  ✓ Logo inserted successfully (200x80 px)'
      logo_replaced = true
    rescue StandardError => e
      puts "  ✗ Error inserting logo: #{e.message}"
    end

    break # Only replace first occurrence
  end

  puts '  ⚠ Logo placeholder _society_logo_ not found in document' unless logo_replaced
else
  puts "\n⚠ Warning: Logo file not found at #{logo_path}"
  puts '  Skipping logo replacement'
end

# Save the document
puts "\nSaving document to: #{output_path}"
begin
  doc.save(output_path)
  puts '✅ Document saved successfully!'
rescue StandardError => e
  puts "❌ Error saving document: #{e.message}"
  exit 1
end

# Display summary
puts "\n#{'=' * 50}"
puts 'REPLACEMENT SUMMARY'
puts '=' * 50
puts "Template: #{template_path}"
puts "Output:   #{output_path}"
puts "Total text replacements: #{mock_data.keys.count}"
puts "Logo replaced: #{File.exist?(logo_path) ? 'Yes' : 'No'}"
puts "\nMock data used:"
mock_data.each do |key, value|
  puts "  #{key.ljust(25)} => #{value}"
end
puts '=' * 50
puts "\n✨ Process completed successfully!"
