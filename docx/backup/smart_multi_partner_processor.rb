# frozen_string_literal: true

require 'bundler/setup'
require 'docx'
require 'extensobr'

class SmartMultiPartnerProcessor
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
  end

  def process(data, start_delimiter = '_', end_delimiter = '_')
    puts "\n📋 Processing contract with #{data[:partners].size} partners..."

    # Build basic replacements (non-partner fields)
    replacements = build_basic_replacements(data)

    # Handle multiple partners intelligently
    handle_multiple_partners(data[:partners], data[:capital], start_delimiter, end_delimiter)

    # Apply basic field replacements
    replace_fields(replacements, start_delimiter, end_delimiter)

    @doc
  end

  delegate :save, to: :@doc

  private

  def handle_multiple_partners(partners, capital, start_delimiter, end_delimiter)
    partner_pattern = "#{start_delimiter}partner#{end_delimiter}"

    # Strategy 1: Handle partner paragraphs (duplicate for each partner)
    handle_partner_paragraphs(partners, partner_pattern)

    # Strategy 2: Handle partner table rows
    handle_partner_table(partners, capital[:partners])

    # Strategy 3: Handle capital distribution paragraphs
    handle_capital_distribution(partners, capital)
  end

  def handle_partner_paragraphs(partners, pattern)
    puts "\n👥 Processing partner paragraphs..."

    paragraphs_to_process = []

    # First pass: identify paragraphs with _partner_ pattern
    @doc.paragraphs.each_with_index do |paragraph, index|
      if paragraph.text.include?(pattern)
        paragraphs_to_process << { paragraph: paragraph, index: index, text: paragraph.text }
      end
    end

    # Process each identified paragraph
    paragraphs_to_process.each do |para_info|
      paragraph = para_info[:paragraph]
      original_text = para_info[:text]

      # Determine context
      if is_list_context?(original_text)
        # It's a list - replace with all partners as a single text block
        all_partners = partners.map.with_index(1) do |partner, idx|
          "#{idx}. #{format_partner(partner)}"
        end.join("\n")

        paragraph.text = original_text.gsub(pattern, all_partners)
      elsif is_capital_context?(original_text)
        # Capital distribution context - handle specially
        # This will be processed in handle_capital_distribution
      else
        # Simple replacement - put all partners in one paragraph
        all_partners = partners.map { |p| format_partner(p) }.join('; ')
        paragraph.text = original_text.gsub(pattern, all_partners)
      end
    end
  end

  def handle_partner_table(partners, capital_partners)
    puts "\n📊 Processing partner table..."

    @doc.tables.each do |table|
      # Check if this is the partners table
      header_row = table.rows.first
      next unless header_row

      # Check if this table has the partner distribution headers
      header_text = header_row.cells.map(&:text).join(' ')
      next unless header_text.include?('Nome dos Sócios') || header_text.include?('Qtd Quotas')

      puts "  Found partners table with #{table.row_count} existing rows"

      # Identify template rows (rows with _partner_ or similar patterns)
      template_rows = []
      data_rows = []

      table.rows.each_with_index do |row, idx|
        next if idx.zero? # Skip header

        row_text = row.cells.map(&:text).join(' ')
        if row_text.include?('_partner') || row_text.include?('TOTAL')
          template_rows << { row: row, index: idx, is_total: row_text.include?('TOTAL') }
        else
          data_rows << { row: row, index: idx }
        end
      end

      puts "  Template rows: #{template_rows.size}, Data rows: #{data_rows.size}"

      # Update existing data rows and template rows
      current_row_index = 1 # Start after header

      # Process each partner
      partners.each_with_index do |partner, _partner_idx|
        capital_info = capital_partners.find { |cp| cp[:name] == partner[:name] }
        next unless capital_info

        next unless current_row_index < table.rows.count

        row = table.rows[current_row_index]

        # Check if this is a template row or existing data row
        row_text = row.cells.map(&:text).join(' ')

        next if row_text.include?('TOTAL')

        # Update the row with partner data
        update_row_cells(row, partner[:name], capital_info)
        current_row_index += 1
      end

      # Update or find the TOTAL row
      total_row_index = partners.size + 1
      if total_row_index < table.rows.count
        total_row = table.rows[total_row_index]
        update_total_row(total_row, capital_partners)
      end
    end
  end

  def handle_capital_distribution(partners, capital)
    puts "\n💰 Processing capital distribution paragraphs..."

    # Find paragraphs that describe individual partner capital contributions
    @doc.paragraphs.each do |paragraph|
      text = paragraph.text

      # Pattern for capital distribution lines
      next unless text.include?('subscreve e integraliza')

      # This is a capital distribution paragraph
      next unless text.include?('_partner_')

      # Build the complete capital distribution text for all partners
      distribution_lines = partners.map.with_index do |partner, idx|
        capital_info = capital[:partners].find { |cp| cp[:name] == partner[:name] }
        next unless capital_info

        letter = ('a'..'z').to_a[idx]
        quotes_text = Extenso.numero(capital_info[:quotes])
        value_text = Extenso.moeda(capital_info[:value])

        "#{letter}. O Sócio #{partner[:name]}, subscreve e integraliza neste ato #{capital_info[:quotes]} (#{quotes_text}) quotas no valor de R$ #{format_currency(capital[:quote_value])} (#{Extenso.moeda(capital[:quote_value])}) cada uma, perfazendo o total de R$ #{format_currency(capital_info[:value])} (#{value_text})"
      end.compact.join(";\n")

      # Replace the entire paragraph
      paragraph.text = "#{distribution_lines}."
    end
  end

  def update_row_cells(row, partner_name, capital_info)
    # Update each cell in the row
    if row.cells[0]
      cell = row.cells[0]
      if cell.paragraphs.any?
        cell.paragraphs.first.text = partner_name
      else
        cell.text = partner_name
      end
    end

    if row.cells[1]
      cell = row.cells[1]
      if cell.paragraphs.any?
        cell.paragraphs.first.text = capital_info[:quotes].to_s
      else
        cell.text = capital_info[:quotes].to_s
      end
    end

    if row.cells[2]
      cell = row.cells[2]
      if cell.paragraphs.any?
        cell.paragraphs.first.text = format_currency(capital_info[:value])
      else
        cell.text = format_currency(capital_info[:value])
      end
    end

    return unless row.cells[3]

    cell = row.cells[3]
    if cell.paragraphs.any?
      cell.paragraphs.first.text = capital_info[:percentage].round(2).to_s
    else
      cell.text = capital_info[:percentage].round(2).to_s
    end
  end

  def update_total_row(row, capital_partners)
    total_quotes = capital_partners.sum { |cp| cp[:quotes] }
    total_value = capital_partners.sum { |cp| cp[:value] }

    if row.cells[0]
      cell = row.cells[0]
      cell.paragraphs.first.text = 'TOTAL:' if cell.paragraphs.any?
    end

    if row.cells[1]
      cell = row.cells[1]
      cell.paragraphs.first.text = total_quotes.to_s if cell.paragraphs.any?
    end

    if row.cells[2]
      cell = row.cells[2]
      cell.paragraphs.first.text = format_currency(total_value) if cell.paragraphs.any?
    end

    return unless row.cells[3]

    cell = row.cells[3]
    return unless cell.paragraphs.any?

    cell.paragraphs.first.text = '100,00'
  end

  def is_list_context?(text)
    # Simple list detection
    text.match?(/^\s*\d+\.\s*_partner_/) ||
      text.match?(/^\s*[a-z]\.\s*_partner_/i)
  end

  def is_capital_context?(text)
    text.include?('subscreve') || text.include?('integraliza')
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

  def format_currency(value)
    '%.2f' % value.to_f.round(2)
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

      # For backwards compatibility with existing template fields
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
end
