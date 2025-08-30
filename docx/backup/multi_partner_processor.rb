# frozen_string_literal: true

require 'bundler/setup'
require 'docx'
require 'extensobr'

class MultiPartnerProcessor
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
  end

  def process(data, start_delimiter = '_', end_delimiter = '_')
    # Build basic replacements (non-partner fields)
    replacements = build_basic_replacements(data)

    # Handle partner fields specially
    handle_partner_fields(data[:partners], start_delimiter, end_delimiter)

    # Apply basic field replacements
    replace_fields(replacements, start_delimiter, end_delimiter)

    # Process partners table
    process_partners_table(data[:partners], data[:capital])

    @doc
  end

  delegate :save, to: :@doc

  private

  # Strategy 1: Paragraph Duplication
  def handle_partner_fields(partners, start_delimiter, end_delimiter)
    puts "\n👥 Processing #{partners.size} partners with dynamic line creation..."

    partner_pattern = "#{start_delimiter}partner#{end_delimiter}"

    @doc.paragraphs.each_with_index do |paragraph, para_index|
      full_text = paragraph.text

      # Check if this paragraph contains the partner placeholder
      next unless full_text.include?(partner_pattern)

      puts "  Found partner paragraph: '#{full_text[0..80]}...'"

      # Determine the context - are we in a list or standalone paragraph?
      if is_partner_list_context?(full_text)
        duplicate_paragraph_for_partners(paragraph, partners, para_index)
      else
        # Single paragraph context - replace with all partners
        all_partners_text = partners.map.with_index(1) do |partner, index|
          "#{index}. #{format_partner(partner)}"
        end.join("\n\n")

        new_text = full_text.gsub(partner_pattern, all_partners_text)
        paragraph.text = new_text
      end
    end
  end

  # Strategy 2: Context-Aware Partner Insertion
  def duplicate_paragraph_for_partners(original_paragraph, partners, _original_index)
    puts "    Duplicating paragraph for #{partners.size} partners..."

    # Get the parent node to insert new paragraphs
    original_paragraph.node.parent
    original_node = original_paragraph.node

    # Create a paragraph for each partner
    partners.each_with_index do |partner, index|
      if index.zero?
        # Replace the original paragraph
        partner_text = original_paragraph.text.gsub('_partner_', format_partner(partner))
        original_paragraph.text = partner_text
      else
        # Clone the original paragraph node
        new_para_node = original_node.dup

        # Insert the new paragraph after the previous one
        if index == 1
          original_node.add_next_sibling(new_para_node)
        else
          # Find the last inserted paragraph and add after it
          previous_sibling = original_node
          index.times { previous_sibling = previous_sibling.next_sibling }
          previous_sibling.add_next_sibling(new_para_node)
        end

        # Create a new Paragraph object and set its text
        new_paragraph = Docx::Elements::Containers::Paragraph.new(new_para_node)
        partner_text = new_paragraph.text.gsub('_partner_', format_partner(partner))
        new_paragraph.text = partner_text
      end
    end
  end

  # Strategy 3: Smart Pattern Detection
  def is_partner_list_context?(text)
    # Detect if we're in a list context vs. a single paragraph context
    list_indicators = [
      /^\s*[a-z]\.\s*_partner_/i,     # "a. _partner_"
      /^\s*\d+\.\s*_partner_/,        # "1. _partner_"
      /^\s*[-•]\s*_partner_/,         # "- _partner_" or "• _partner_"
      /;\s*_partner_/ # "previous partner; _partner_"
    ]

    list_indicators.any? { |pattern| text.match?(pattern) }
  end

  def format_partner(partner)
    text = "#{partner[:name]}, #{partner[:nationality]}, #{partner[:civil_status]}"
    text += ", natural da cidade de #{partner[:birth_city]}"
    text += ", inscrito na OAB/#{partner[:oab_state]} sob nº #{partner[:oab_number]}"
    text += ", nascido(a) em #{partner[:birth_date]}"
    text += ", #{partner[:profession]}"
    text += ", n° do CPF #{partner[:cpf]}"
    text += ", residente e domiciliado na cidade de #{partner[:city]} - #{partner[:state]}"
    text += ", na #{partner[:address]}, nº #{partner[:number]}"
    text += ", #{partner[:complement]}, #{partner[:neighborhood]}, CEP: #{partner[:zip_code]}"
    text
  end

  def build_basic_replacements(data)
    replacements = {}

    # Society info
    if data[:society]
      replacements['society_name'] = data[:society][:name]
      replacements['city'] = data[:society][:city]
      replacements['state'] = data[:society][:state]
      replacements['address'] = data[:society][:address]
      replacements['zip_code'] = data[:society][:zip_code] if data[:society][:zip_code]
    end

    # Capital info
    if data[:capital]
      capital = data[:capital]
      replacements['total_value'] = format_currency(capital[:total_value])
      replacements['quotes'] = capital[:total_quotes].to_s
      replacements['quote_value'] = format_currency(capital[:quote_value])
      replacements['total_quotes'] = capital[:total_quotes].to_s
      replacements['sum'] = Extenso.moeda(capital[:total_value])
      replacements['sum_percentage'] = '100,00'

      # Individual partner values (for first partner as example)
      if capital[:partners].any?
        first_partner = capital[:partners].first
        replacements['parner_valute'] = first_partner[:quotes].to_s
        replacements['partner_quotes'] = first_partner[:quotes].to_s
        replacements['value'] = format_currency(first_partner[:value])
        replacements['percentage'] = first_partner[:percentage].round(2).to_s
      end
    end

    replacements
  end

  def format_currency(value)
    '%.2f' % value.to_f.round(2)
  end

  def replace_fields(replacements, start_delimiter, end_delimiter)
    @doc.paragraphs.each do |paragraph|
      replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
    end

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

  def replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
    full_text = paragraph.text
    original_text = full_text.dup

    replacements.each do |field_name, replacement_value|
      field_pattern = "#{start_delimiter}#{field_name}#{end_delimiter}"
      full_text = full_text.gsub(field_pattern, replacement_value.to_s)
    end

    return unless full_text != original_text

    paragraph.text = full_text
  end

  def process_partners_table(partners, capital)
    @doc.tables.each do |table|
      header_row = table.rows.first
      next unless header_row&.cells&.any? { |cell| cell.text.include?('Nome dos Sócios') }

      puts "📊 Processing partners table with #{partners.size} partners..."

      # Update existing rows and add new ones as needed
      partners.each_with_index do |partner, index|
        partner_capital = capital[:partners].find { |pc| pc[:name] == partner[:name] }
        next unless partner_capital

        row_index = index + 1 # +1 for header row

        row = if row_index < table.rows.count
                # Update existing row
                table.rows[row_index]
              else
                # Add new row
                table.add_row
              end

        update_table_cell(row, 0, partner[:name])
        update_table_cell(row, 1, partner_capital[:quotes].to_s)
        update_table_cell(row, 2, format_currency(partner_capital[:value]))
        update_table_cell(row, 3, partner_capital[:percentage].round(2).to_s)
      end

      # Add total row
      total_row_index = partners.size + 1
      total_row = if total_row_index < table.rows.count
                    table.rows[total_row_index]
                  else
                    table.add_row
                  end

      update_table_cell(total_row, 0, 'TOTAL:')
      update_table_cell(total_row, 1, capital[:total_quotes].to_s)
      update_table_cell(total_row, 2, format_currency(capital[:total_value]))
      update_table_cell(total_row, 3, '100,00')
    end
  end

  def update_table_cell(row, cell_index, new_text)
    return unless row.cells[cell_index]

    cell = row.cells[cell_index]
    if cell.paragraphs.any?
      cell.paragraphs.first.text = new_text
    else
      cell.text = new_text
    end
  end
end
