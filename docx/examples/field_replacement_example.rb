#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/docx'

# Example: Universal Field Replacement
# This example demonstrates the new field replacement feature that handles
# split text runs correctly

def basic_example
  puts '=== Basic Field Replacement Example ==='

  # Open a template document
  doc = Docx::Document.open('template.docx')

  # Define replacements - much simpler than the old way!
  replacements = {
    'company_name' => 'ACME Corporation',
    'client_name' => 'John Doe',
    'date' => Time.zone.today.strftime('%B %d, %Y'),
    'contract_number' => 'CTR-2024-001',
    'amount' => '50,000.00',
    'payment_terms' => '30 days'
  }

  # Replace all fields in one call
  doc.replace_fields(replacements)

  # Save the result
  doc.save('output_basic.docx')
  puts '✅ Document saved as output_basic.docx'
end

def custom_delimiter_example
  puts "\n=== Custom Delimiter Example ==="

  # For templates using {{field}} instead of _field_
  doc = Docx::Document.open('template_curly.docx')

  replacements = {
    'name' => 'Jane Smith',
    'position' => 'Senior Developer',
    'department' => 'Engineering'
  }

  # Use custom delimiters
  doc.replace_fields(replacements, '{{', '}}')

  doc.save('output_curly.docx')
  puts '✅ Document with {{}} delimiters saved'
end

def table_example
  puts "\n=== Table Processing Example ==="

  doc = Docx::Document.open('invoice_template.docx')

  # Invoice data
  invoice_data = {
    'invoice_number' => 'INV-2024-0042',
    'invoice_date' => Time.zone.today.to_s,
    'client_name' => 'Tech Startup Inc.',
    'client_address' => '123 Main St, San Francisco, CA 94102',
    'subtotal' => '5,000.00',
    'tax' => '500.00',
    'total' => '5,500.00'
  }

  # Replace fields
  doc.replace_fields(invoice_data)

  # Process table rows for line items
  items = [
    { desc: 'Web Development', qty: 40, rate: 100, total: 4000 },
    { desc: 'UI/UX Design', qty: 10, rate: 100, total: 1000 }
  ]

  doc.tables.each do |table|
    # Find the items table (look for specific header text)
    header_row = table.rows.first
    next unless header_row&.cells&.any? { |c| c.text.include?('Description') }

    # Update rows with item data
    items.each_with_index do |item, idx|
      row_index = idx + 1 # Skip header
      next unless row_index < table.rows.count

      row = table.rows[row_index]
      row.cells[0].text = item[:desc] if row.cells[0]
      row.cells[1].text = item[:qty].to_s if row.cells[1]
      row.cells[2].text = "$#{item[:rate]}" if row.cells[2]
      row.cells[3].text = "$#{item[:total]}" if row.cells[3]
    end
  end

  doc.save('output_invoice.docx')
  puts '✅ Invoice with table data saved'
end

def multiple_items_example
  puts "\n=== Multiple Items (Partners) Example ==="

  doc = Docx::Document.open('partnership_template.docx')

  # Partner data
  partners = [
    { name: 'Alice Johnson', role: 'Managing Partner', equity: '40%' },
    { name: 'Bob Smith', role: 'Senior Partner', equity: '35%' },
    { name: 'Carol White', role: 'Junior Partner', equity: '25%' }
  ]

  # Create a single replacement for all partners
  partner_list = partners.map do |p|
    "#{p[:name]}, #{p[:role]} (#{p[:equity]} equity)"
  end.join("\n")

  replacements = {
    'company_name' => 'Johnson, Smith & White LLP',
    'formation_date' => Time.zone.today.to_s,
    'partners' => partner_list,
    'total_partners' => partners.size.to_s,
    'state' => 'California'
  }

  doc.replace_fields(replacements)
  doc.save('output_partnership.docx')
  puts "✅ Partnership agreement with #{partners.size} partners saved"
end

# Run examples (comment out if templates don't exist)
begin
  basic_example
rescue Errno::ENOENT => e
  puts "⚠️  Skipping basic example: #{e.message}"
end

begin
  custom_delimiter_example
rescue Errno::ENOENT => e
  puts "⚠️  Skipping custom delimiter example: #{e.message}"
end

begin
  table_example
rescue Errno::ENOENT => e
  puts "⚠️  Skipping table example: #{e.message}"
end

begin
  multiple_items_example
rescue Errno::ENOENT => e
  puts "⚠️  Skipping multiple items example: #{e.message}"
end

puts "\n📝 Note: Create template files to run the examples successfully."
puts 'Templates should contain fields like _field_name_ or {{field_name}}'
