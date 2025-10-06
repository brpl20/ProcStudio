#!/usr/bin/env ruby
# frozen_string_literal: true

# Debug script to trace placeholder substitution in tables
# Usage: rails runner rails_runner_tests/debug_table_placeholders.rb

puts "="*80
puts "Debugging Table Placeholder Substitution"
puts "="*80

require 'docx'
load Rails.root.join('app', 'services', 'docx_services', 'social_contract_service_society_improved.rb')
load Rails.root.join('app', 'services', 'docx_services', 'concerns', 'table_insertable_improved.rb')

office = Office.find(6)
puts "\nOffice: #{office.name}"
puts "Partners: #{office.user_profiles.count}"

# Initialize service
service = DocxServices::SocialContractServiceSociety.new(office.id)

# Open template
template_path = Rails.root.join('app/services/docx_services/templates/CS-TEMPLATE.docx')
doc = ::Docx::Document.open(template_path.to_s)

puts "\n[BEFORE ROW INSERTION]"
puts "Tables count: #{doc.tables.count}"

if doc.tables.any?
  table = doc.tables.first
  puts "First table rows: #{table.rows.count}"
  
  table.rows.each_with_index do |row, row_idx|
    puts "\n  Row #{row_idx + 1}:"
    row.cells.each_with_index do |cell, cell_idx|
      text = cell.paragraphs.map { |p| p.text }.join(' ')
      puts "    Cell [#{row_idx},#{cell_idx}]: #{text}"
    end
  end
end

# Now insert rows for multiple partners
if office.user_profiles.count > 1
  puts "\n[INSERTING ROWS]"
  inserter = DocxServices::Concerns::TableInsertable::TableInserter.new(
    doc,
    entity_type: 'partner',
    placeholders: %w[
      _partner_full_name_1_
      _partner_total_quotes_1_
      _partner_sum_1_
      _%_1_
    ]
  )
  
  rows_to_insert = office.user_profiles.count - 1
  puts "Inserting #{rows_to_insert} rows..."
  
  inserter.insert_blank_rows_with_placeholders(
    count: rows_to_insert,
    table_index: 0,
    after_row_index: 1
  )
end

puts "\n[AFTER ROW INSERTION]"
table = doc.tables.first
puts "First table rows: #{table.rows.count}"

table.rows.each_with_index do |row, row_idx|
  puts "\n  Row #{row_idx + 1}:"
  row.cells.each_with_index do |cell, cell_idx|
    text = cell.paragraphs.map { |p| p.text }.join(' ')
    puts "    Cell [#{row_idx},#{cell_idx}]: #{text}"
  end
end

# Now test substitution
puts "\n[TESTING SUBSTITUTION]"

partners = office.user_profiles
user_formatters = office.user_profiles.map { |user| Formatters::FormatterQualification.new(user) }

# Process each row's cells for substitution
table.rows.each_with_index do |row, row_idx|
  next if row_idx == 0  # Skip header row
  
  puts "\n  Processing Row #{row_idx + 1}:"
  row.cells.each_with_index do |cell, cell_idx|
    cell.paragraphs.each do |paragraph|
      original_text = paragraph.text
      
      # Try substitution for each partner
      partners.each_with_index do |partner, partner_idx|
        partner_number = partner_idx + 1
        formatter = user_formatters[partner_idx]
        
        # Define substitutions
        substitutions = {
          "_partner_full_name_#{partner_number}_" => formatter.full_name || '',
          "_partner_total_quotes_#{partner_number}_" => "13",  # Example value
          "_partner_sum_#{partner_number}_" => "R$ 87,50",     # Example value
          "_%_#{partner_number}_" => "50%"                     # Example value
        }
        
        substitutions.each do |pattern, value|
          if original_text.include?(pattern)
            puts "    Cell [#{row_idx},#{cell_idx}]: Found '#{pattern}'"
            puts "      -> Will replace with: '#{value}'"
            
            # Try the substitution
            paragraph.substitute_across_runs_with_block_regex(pattern) { |_| value }
            
            new_text = paragraph.text
            if new_text != original_text
              puts "      ✓ Substitution successful"
            else
              puts "      ✗ Substitution failed"
            end
          end
        end
      end
    end
  end
end

puts "\n[FINAL TABLE STATE]"
table.rows.each_with_index do |row, row_idx|
  puts "\n  Row #{row_idx + 1}:"
  row.cells.each_with_index do |cell, cell_idx|
    text = cell.paragraphs.map { |p| p.text }.join(' ')
    puts "    Cell [#{row_idx},#{cell_idx}]: #{text}"
  end
end

puts "\n" + "="*80