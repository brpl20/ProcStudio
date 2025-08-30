# frozen_string_literal: true

require 'bundler/setup'
require 'docx'
require 'extensobr'

class ContractProcessor
  def initialize(template_path)
    @template_path = template_path
    @doc = Docx::Document.open(template_path)
  end

  def process(data)
    substitute_society_info(data[:society])
    substitute_partners_info(data[:partners])
    substitute_capital_info(data[:capital])
    process_partners_table(data[:partners], data[:capital])
    substitute_administrators(data[:partners])

    @doc
  end

  delegate :save, to: :@doc

  private

  def substitute_society_info(society)
    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        text.substitute('_society_name_', society[:name])
        text.substitute('_society_city_', society[:city])
        text.substitute('_society_state_', society[:state]) # Changed from _society_state_
        text.substitute('_society_address_', society[:address]) # Changed from _society_address_
        text.substitute('_society_zip_code_', society[:zip_code]) if society[:zip_code] # Added zip_code
      end
    end
  end

  def substitute_partners_info(partners)
    partners_text = partners.map { |partner| format_partner(partner) }.join("\n\n")

    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        text.substitute('_partner_', partners_text)
        text.substitute('_partner_full_name_', partner[:name])
      end
    end
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

  def substitute_capital_info(capital)
    total_value_words = Extenso.moeda(capital[:total_value])
    Extenso.moeda(capital[:quote_value])

    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        # Replace total value and quotes
        text.substitute('_total_value_', format_currency(capital[:total_value]).to_s)
        text.substitute('_quotes_', capital[:total_quotes].to_s)
        text.substitute('_quote_value_', format_currency(capital[:quote_value]).to_s)
        text.substitute('_total_quotes_', capital[:total_quotes].to_s)

        # Replace sum fields
        text.substitute('_sum_', total_value_words)
        text.substitute('_sum_percentage_', '100,00')

        # Replace partner-specific values (typo in template: _parner_valute_)
        text.substitute('_parner_valute_', capital[:partners].first[:quotes].to_s) if capital[:partners].any?
        text.substitute('_partner_quotes_', capital[:partners].first[:quotes].to_s) if capital[:partners].any?
        text.substitute('_value_', format_currency(capital[:partners].first[:value])) if capital[:partners].any?
        text.substitute('_percentage_', capital[:partners].first[:percentage].round(2).to_s) if capital[:partners].any?
      end
    end
  end

  def process_partners_table(partners, capital)
    @doc.tables.each do |table|
      # Find the table with partners (looking for header with "Nome dos Sócios")
      header_row = table.rows.first
      unless header_row&.cells&.any? do |cell|
        cell.text.include?('Nome dos Sócios') || cell.text.include?('Qtd Quotas')
      end
        next
      end

      # Process existing rows instead of deleting/adding
      row_index = 1

      # Update or add partner rows
      capital[:partners].each do |partner_capital|
        partner = partners.find { |p| p[:name] == partner_capital[:name] }
        next unless partner

        if row_index < table.rows.count
          # Update existing row
          row = table.rows[row_index]
          # Replace text in each cell
          row.cells[0].paragraphs.first.text = partner[:name] if row.cells[0]
          row.cells[1].paragraphs.first.text = partner_capital[:quotes].to_s if row.cells[1]
          row.cells[2].paragraphs.first.text = format_currency(partner_capital[:value]) if row.cells[2]
          row.cells[3].paragraphs.first.text = partner_capital[:percentage].round(2).to_s if row.cells[3]
        else
          # Add new row if needed
          new_row = table.add_row
          new_row.cells[0].text = partner[:name]
          new_row.cells[1].text = partner_capital[:quotes].to_s if new_row.cells[1]
          new_row.cells[2].text = format_currency(partner_capital[:value]) if new_row.cells[2]
          new_row.cells[3].text = partner_capital[:percentage].round(2).to_s if new_row.cells[3]
        end
        row_index += 1
      end

      # Update or add total row
      if row_index < table.rows.count
        # Update existing total row
        row = table.rows[row_index]
        row.cells[0].paragraphs.first.text = 'TOTAL:' if row.cells[0]
        row.cells[1].paragraphs.first.text = capital[:total_quotes].to_s if row.cells[1]
        row.cells[2].paragraphs.first.text = format_currency(capital[:total_value]) if row.cells[2]
        row.cells[3].paragraphs.first.text = '100,00' if row.cells[3]
      else
        # Add total row
        total_row = table.add_row
        total_row.cells[0].text = 'TOTAL:'
        total_row.cells[1].text = capital[:total_quotes].to_s if total_row.cells[1]
        total_row.cells[2].text = format_currency(capital[:total_value]) if total_row.cells[2]
        total_row.cells[3].text = '100,00' if total_row.cells[3]
      end
    end
  end

  def substitute_administrators(partners)
    administrators = partners.select { |p| p[:is_administrator] }

    # Find paragraphs that mention administration and have _partner_ field
    @doc.paragraphs.each do |paragraph|
      next unless paragraph.text.include?('será administrada') && paragraph.text.include?('_partner_')

      paragraph.each_text_run do |text|
        if administrators.any?
          if administrators.size == 1
            admin = administrators.first
            text.substitute('_partner_', admin[:name])
          else
            names = administrators.map { |a| a[:name] }.join(' e ')
            text.substitute('_partner_', names)
          end
        end
      end
    end
  end

  def format_currency(value)
    '%.2f' % value.to_f.round(2)
  end
end
