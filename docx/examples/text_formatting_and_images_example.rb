#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'docx'

# Open an existing document or create a new one
doc = begin
  Docx::Document.open('examples/basic_template.docx')
rescue StandardError
  Docx::Document.open('spec/fixtures/basic.docx')
end

puts 'Adding formatted text examples...'

# Add a heading
doc.add_paragraph('Text Formatting Examples', bold: true, size: 18)
doc.add_paragraph('') # Empty line

# Add paragraphs with different formatting
doc.add_bold_paragraph('This is a bold paragraph')
doc.add_italic_paragraph('This is an italic paragraph')
doc.add_paragraph('This has mixed formatting', bold: true, italic: true, size: 14, color: 'FF0000')

# Add a paragraph with multiple text runs
para = doc.add_paragraph
para.add_text('This paragraph has ')
para.add_bold_text('bold text')
para.add_text(', ')
para.add_italic_text('italic text')
para.add_text(', and ')
para.add_text('colored text', color: '0000FF', size: 16)
para.add_text(' all in one line!')

doc.add_paragraph('') # Empty line

# Modify existing paragraph formatting
if doc.paragraphs.any?
  existing_para = doc.paragraphs.first
  if existing_para.text_runs.any?
    run = existing_para.text_runs.first
    run.bold!
    run.color = '008000' # Green
    run.font_size = 12
    puts 'Modified first paragraph to be bold, green, and 12pt'
  end
end

# Add images if they exist
doc.add_paragraph('')
doc.add_paragraph('Image Examples', bold: true, size: 18)
doc.add_paragraph('')

# Check for sample images
image_paths = [
  'spec/fixtures/replacement.png',
  'examples/sample.jpg',
  'examples/logo.png'
]

image_paths.each do |path|
  next unless File.exist?(path)

  puts "Adding image: #{path}"
  doc.add_paragraph("Image from: #{path}")
  doc.add_image(path, width: 300, height: 200)
  doc.add_paragraph('') # Space after image
  break # Only add the first available image
end

# Save the modified document
output_path = 'examples/formatted_output.docx'
doc.save(output_path)
puts "Document saved to: #{output_path}"

# Display some statistics
puts "\nDocument Statistics:"
puts "Total paragraphs: #{doc.paragraphs.count}"
puts "Total text runs: #{doc.paragraphs.map(&:text_runs).flatten.count}"

# Show formatting status of first few paragraphs
puts "\nFormatting of first 5 paragraphs:"
doc.paragraphs.first(5).each_with_index do |para, i|
  text = para.to_s[0..50]
  text += '...' if para.to_s.length > 50

  formatting = []
  para.text_runs.each do |run|
    formatting << 'bold' if run.bolded?
    formatting << 'italic' if run.italicized?
    formatting << 'underline' if run.underlined?
  end

  format_str = formatting.empty? ? 'plain' : formatting.uniq.join(', ')
  puts "  #{i + 1}. [#{format_str}] #{text}"
end
