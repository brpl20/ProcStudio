# frozen_string_literal: true

require 'bundler/setup'
require 'docx'
require 'extensobr'

class EnhancedContractProcessor
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
  end

  def process(data, start_delimiter = '_', end_delimiter = '_')
    # Build all replacements map
    replacements = build_replacements_map(data)

    puts "\n📋 Processing #{replacements.size} field replacements..."
    replacements.each { |k, v| puts "  #{start_delimiter}#{k}#{end_delimiter} => #{v[0..50]}#{'...' if v.length > 50}" }

    # Apply universal field replacement
    replace_fields(replacements, start_delimiter, end_delimiter)

    # Process table rows for partners
    process_partners_table(data[:partners], data[:capital])

    @doc
  end

  delegate :save, to: :@doc

  private

  def build_replacements_map(data)
    replacements = {}

    # Society info
    if data[:society]
      replacements['society_name'] = data[:society][:name]
      replacements['city'] = data[:society][:city]
      replacements['state'] = data[:society][:state]
      replacements['address'] = data[:society][:address]
      replacements['zip_code'] = data[:society][:zip_code] if data[:society][:zip_code]
    end

    # Partners info
    if data[:partners]
      partners_text = data[:partners].map { |partner| format_partner(partner) }.join("\n\n")
      replacements['partner'] = partners_text
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

      # Individual partner values (for template fields like _parner_valute_)
      if capital[:partners].any?
        first_partner = capital[:partners].first
        replacements['parner_valute'] = first_partner[:quotes].to_s # NOTE: typo in template
        replacements['partner_quotes'] = first_partner[:quotes].to_s
        replacements['value'] = format_currency(first_partner[:value])
        replacements['percentage'] = first_partner[:percentage].round(2).to_s
      end
    end

    replacements
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
    text += ';'
    text
  end

  def format_currency(value)
    '%.2f' % value.to_f.round(2)
  end

  # Universal field replacement that works regardless of text run splitting
  def replace_fields(replacements, start_delimiter, end_delimiter)
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

  def replace_in_paragraph(paragraph, replacements, start_delimiter, end_delimiter)
    full_text = paragraph.text
    original_text = full_text.dup

    # Apply all replacements to get the target text
    replacements.each do |field_name, replacement_value|
      field_pattern = "#{start_delimiter}#{field_name}#{end_delimiter}"
      full_text = full_text.gsub(field_pattern, replacement_value.to_s)
    end

    # If text changed, update the paragraph
    return unless full_text != original_text

    # Simple approach: replace the entire paragraph text
    # This loses some formatting but ensures reliability
    paragraph.text = full_text
  end

  def process_partners_table(partners, capital)
    @doc.tables.each do |table|
      # Find partner distribution table
      header_row = table.rows.first
      unless header_row&.cells&.any? do |cell|
        cell.text.include?('Nome dos Sócios') || cell.text.include?('Qtd Quotas')
      end
        next
      end

      puts '📊 Processing partners table...'

      # Update partner rows
      row_index = 1
      capital[:partners].each do |partner_capital|
        partner = partners.find { |p| p[:name] == partner_capital[:name] }
        next unless partner

        if row_index < table.rows.count
          row = table.rows[row_index]
          update_table_cell(row, 0, partner[:name])
          update_table_cell(row, 1, partner_capital[:quotes].to_s)
          update_table_cell(row, 2, format_currency(partner_capital[:value]))
          update_table_cell(row, 3, partner_capital[:percentage].round(2).to_s)
        end
        row_index += 1
      end

      # Update total row if exists
      next unless row_index < table.rows.count

      total_row = table.rows[row_index]
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
