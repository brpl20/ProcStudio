#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'docx'

class FieldDebugger
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
    @found_fields = []
  end

  def scan_document
    puts "\n========================================="
    puts "SCANNING DOCUMENT: #{@template_path}"
    puts '========================================='

    # Scan paragraphs
    puts "\n📄 SCANNING PARAGRAPHS:"
    puts '-' * 40

    @doc.paragraphs.each_with_index do |paragraph, p_index|
      text = paragraph.text

      # Find all patterns that match _something_
      fields = text.scan(/_[a-zA-Z_]+_/)

      if fields.any?
        puts "\nParagraph ##{p_index + 1}:"
        puts "  Full text: #{text[0..100]}#{'...' if text.length > 100}"
        puts '  Found fields:'
        fields.uniq.each do |field|
          puts "    ✓ #{field}"
          @found_fields << field
        end
      end

      # Also check each text run separately
      paragraph.each_text_run do |text_run|
        run_text = text_run.text
        run_fields = run_text.scan(/_[a-zA-Z_]+_/)

        next unless run_fields.any? && run_fields != fields

        puts '  Text run contains:'
        run_fields.uniq.each do |field|
          puts "    → #{field} (in text run: '#{run_text}')"
        end
      end
    end

    # Scan tables
    puts "\n📊 SCANNING TABLES:"
    puts '-' * 40

    @doc.tables.each_with_index do |table, t_index|
      puts "\nTable ##{t_index + 1} (#{table.rows.count} rows):"

      table.rows.each_with_index do |row, r_index|
        row.cells.each_with_index do |cell, c_index|
          cell_text = cell.text
          fields = cell_text.scan(/_[a-zA-Z_]+_/)

          if fields.any?
            puts "  Row #{r_index + 1}, Cell #{c_index + 1}:"
            puts "    Text: #{cell_text}"
            puts '    Fields found:'
            fields.uniq.each do |field|
              puts "      ✓ #{field}"
              @found_fields << field
            end
          end

          # Check paragraphs within cells
          cell.paragraphs.each do |para|
            para_fields = para.text.scan(/_[a-zA-Z_]+_/)
            if para_fields.any? && para_fields != fields
              puts "    Cell paragraph contains: #{para_fields.uniq.join(', ')}"
            end
          end
        end
      end
    end

    # Summary
    puts "\n========================================="
    puts '📋 SUMMARY OF ALL UNIQUE FIELDS FOUND:'
    puts '========================================='

    unique_fields = @found_fields.uniq.sort
    if unique_fields.any?
      unique_fields.each_with_index do |field, index|
        puts "#{index + 1}. #{field}"
      end
      puts "\nTotal unique fields: #{unique_fields.count}"
    else
      puts '❌ No fields with pattern _fieldname_ found!'
    end

    # Check for potential broken patterns
    puts "\n⚠️  CHECKING FOR BROKEN PATTERNS:"
    puts '-' * 40

    broken_patterns = []
    @doc.paragraphs.each do |paragraph|
      text = paragraph.text
      # Look for single underscores that might be part of a broken field
      broken_patterns << text[0..100] if text.match(/[^_]_[a-zA-Z]/) || text.match(/[a-zA-Z]_[^_]/)
    end

    if broken_patterns.any?
      puts 'Found potential broken field patterns:'
      broken_patterns.each do |pattern|
        puts "  - #{pattern}#{'...' if pattern.length >= 100}"
      end
    else
      puts 'No broken patterns detected.'
    end

    puts "\n========================================="
    puts 'SCAN COMPLETE!'
    puts '========================================='
  end
end

# Run the debugger
template_file = ARGV[0] || 'CS-TEMPLATE.docx'

begin
  debugger = FieldDebugger.new(template_file)
  debugger.scan_document
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
end
