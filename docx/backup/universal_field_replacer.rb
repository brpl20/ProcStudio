#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'docx'

class UniversalFieldReplacer
  def initialize(document_path)
    @doc = Docx::Document.open(document_path)
  end

  # Replace fields in the entire document using any delimiter pattern
  def replace_fields(replacements, start_delimiter = '_', end_delimiter = '_')
    # Process paragraphs
    @doc.paragraphs.each do |paragraph|
      replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
    end

    # Process tables
    @doc.tables.each do |table|
      table.rows.each do |row|
        row.cells.each do |cell|
          cell.paragraphs.each do |paragraph|
            replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
          end
        end
      end
    end
  end

  delegate :save, to: :@doc

  private

  def replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
    # Get the full paragraph text
    full_text = paragraph.text
    original_text = full_text.dup

    # Find and replace all field patterns
    replacements.each do |field_name, replacement_value|
      field_pattern = "#{start_delimiter}#{field_name}#{end_delimiter}"
      full_text = full_text.gsub(field_pattern, replacement_value.to_s)
    end

    # If text was changed, we need to reconstruct the paragraph
    return unless full_text != original_text

    puts "Replacing in paragraph: #{original_text[0..80]}..."
    puts "  New text: #{full_text[0..80]}..."
    reconstruct_paragraph(paragraph, full_text, original_text, replacements, start_delimiter, end_delimiter)
  end

  def reconstruct_paragraph(paragraph, _new_text, original_text, replacements, start_delimiter, end_delimiter)
    # Strategy: Replace text runs sequentially to maintain formatting

    # Get all text runs
    text_runs = paragraph.text_runs

    return if text_runs.empty?

    # Build a map of original text positions to runs
    current_pos = 0
    run_map = []

    text_runs.each_with_index do |run, index|
      run_text = run.text
      run_map << {
        run: run,
        index: index,
        start_pos: current_pos,
        end_pos: current_pos + run_text.length,
        text: run_text
      }
      current_pos += run_text.length
    end

    # Find which replacements affected this paragraph
    affected_replacements = []
    replacements.each do |field_name, replacement_value|
      field_pattern = "#{start_delimiter}#{field_name}#{end_delimiter}"
      next unless original_text.include?(field_pattern)

      affected_replacements << {
        pattern: field_pattern,
        replacement: replacement_value.to_s,
        start: original_text.index(field_pattern),
        end: original_text.index(field_pattern) + field_pattern.length
      }
    end

    # Sort replacements by position (earliest first)
    affected_replacements.sort_by! { |r| r[:start] }

    # Process each replacement
    affected_replacements.each do |repl|
      # Find which runs are affected by this replacement
      affected_runs = run_map.select do |rm|
        # Run overlaps with the replacement range
        rm[:start_pos] < repl[:end] && rm[:end_pos] > repl[:start]
      end

      next unless affected_runs.any?

      # Clear all affected runs except the first one
      affected_runs[1..].each do |rm|
        rm[:run].text = ''
      end

      # Calculate the replacement in context
      first_run = affected_runs.first
      last_run = affected_runs.last

      # Get the text segment that includes the replacement
      segment_start = first_run[:start_pos]
      segment_end = last_run[:end_pos]
      segment_text = original_text[segment_start...segment_end]

      # Replace the pattern in this segment
      new_segment = segment_text.gsub(repl[:pattern], repl[:replacement])

      # Set the new text in the first run
      first_run[:run].text = new_segment
    end
  end
end

# Test the universal replacer
if __FILE__ == $PROGRAM_NAME
  # Test with different delimiter styles
  test_cases = [
    {
      delimiters: ['_', '_'],
      replacements: {
        'society_name' => 'PELLIZZETTI E WALBER ADVOGADOS ASSOCIADOS',
        'city' => 'Cascavel',
        'state' => 'PR',
        'address' => 'Rua Paraná, 3045, Sala 1204, Centro',
        'zip_code' => '85810-010',
        'partner' => 'BRUNO PELLIZZETTI, brasileiro, solteiro...',
        'total_value' => '10.000,00'
      }
    }
    # Could easily add support for other patterns:
    # {
    #   delimiters: ['{{', '}}'],
    #   replacements: { 'company_name' => 'Test Company' }
    # }
  ]

  test_cases.each_with_index do |test_case, index|
    puts "\n#{'=' * 60}"
    puts "TEST CASE #{index + 1}: #{test_case[:delimiters].join('field_name')}"
    puts '=' * 60

    replacer = UniversalFieldReplacer.new('CS-TEMPLATE.docx')
    replacer.replace_fields(
      test_case[:replacements],
      test_case[:delimiters][0],
      test_case[:delimiters][1]
    )

    output_file = "CS-UNIVERSAL-#{index + 1}-#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.docx"
    replacer.save(output_file)

    puts "✅ Generated: #{output_file}"
  end
end
