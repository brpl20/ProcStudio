#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'docx'

class TextRunDebugger
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
  end

  def analyze
    puts "\n#{'=' * 60}"
    puts "TEXT RUN ANALYSIS FOR: #{@template_path}"
    puts '=' * 60

    # Look for specific fields we're trying to replace
    target_fields = ['_society_name_', '_partner_', '_city_', '_state_', '_address_', '_total_value_']

    target_fields.each do |field|
      puts "\n🔍 Looking for: #{field}"
      puts '-' * 40

      found = false

      @doc.paragraphs.each_with_index do |paragraph, p_idx|
        full_text = paragraph.text

        next unless full_text.include?(field)

        found = true
        puts "\n✓ Found in Paragraph ##{p_idx + 1}"
        puts "  Full paragraph text: #{full_text[0..100]}#{'...' if full_text.length > 100}"
        puts "\n  Text runs breakdown:"

        run_texts = []
        r_idx = 0
        paragraph.each_text_run do |text_run|
          r_idx += 1
          puts "    Run ##{r_idx}: '#{text_run.text}'"
          run_texts << text_run.text

          # Check if the field is split across runs
          if text_run.text.include?(field)
            puts '      ✅ COMPLETE field in this run'
          elsif text_run.text.include?('_')
            puts '      ⚠️  Contains underscore - might be part of split field'
          end
        end

        # Try to reconstruct from runs
        reconstructed = run_texts.join
        next unless reconstructed != full_text

        puts "\n  ⚠️ WARNING: Reconstructed text differs from paragraph.text!"
        puts "    Paragraph.text: #{full_text}"
        puts "    Reconstructed:  #{reconstructed}"
      end

      puts '  ❌ Not found in any paragraph' unless found
    end

    puts "\n#{'=' * 60}"
    puts 'ANALYSIS COMPLETE'
    puts '=' * 60
  end
end

# Run the debugger
debugger = TextRunDebugger.new('CS-TEMPLATE.docx')
debugger.analyze
