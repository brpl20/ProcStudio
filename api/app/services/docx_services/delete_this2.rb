

add_partner_rows_to_tables

doc.tables.each do |table|
  table.rows.each do |row|
    row.cells.each do |cell|
      cell.paragraphs.each do |paragraph|
        substitute_placeholders_with_block_regex(paragraph)
      end
    end
  end
end


# frozen_string_literal: true

require 'docx'

module DocxServices
  # Handles social contract generation for multiple lawyers (society)
  # rubocop:disable Metrics/ClassLength
  class SocialContractServiceSociety < BaseTemplate
    attr_reader :office_formatter, :doc, :file_path

    def initialize(*args)
      super
      @office_formatter = FormatterOffices.for_office(office, lawyers)
    end

    def process_document
      @doc = ::Docx::Document.open(template_path)
      @file_path = Rails.root.join('tmp', file_name)

      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

      add_partner_rows_to_tables

      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              substitute_placeholders_with_block(paragraph)
            end
          end
        end
      end

      doc.save(file_path)
    end

    protected

    def template_path
      'tests/CS-TEMPLATE.docx'
    end

    def file_name
      "cs-#{office.name}.docx"
    end

    private

    def substitute_placeholders_with_block(paragraph)
      substitute_office_fields(paragraph)
      substitute_multiple_partner_fields(paragraph)
      substitute_capital_fields(paragraph)
      substitute_pro_labore_dividends_clauses(paragraph)
      substitute_date_field(paragraph)
    end

    def substitute_office_fields(paragraph)
      paragraph.substitute_across_runs_with_block(/_office_name_/) do |_|
        office_name
      end

      paragraph.substitute_across_runs_with_block(/_office_city_/) do |_|
        office_city
      end

      paragraph.substitute_across_runs_with_block(/_office_state_/) do |_|
        office_state
      end

      paragraph.substitute_across_runs_with_block(/_office_address_/) do |_|
        office_street
      end

      paragraph.substitute_across_runs_with_block(/_office_zip_code_/) do |_|
        office_zip_code
      end

      paragraph.substitute_across_runs_with_block(/_office_total_value_/) do |_|
        format_currency(total_capital_value)
      end

      paragraph.substitute_across_runs_with_block(/_office_quotes_/) do |_|
        format_number(total_quotes)
      end

      paragraph.substitute_across_runs_with_block(/_office_quote_value_/) do |_|
        "#{quote_value.to_i},00"
      end
    end

    def substitute_multiple_partner_fields(paragraph)
      paragraph.substitute_across_runs_with_block(/_partner_qualification_/) do |_|
        partner_qualification_text
      end

      paragraph.substitute_across_runs_with_block(/_partner_full_name_/) do |_|
        partner_full_name_text
      end

      paragraph.substitute_across_runs_with_block(/_partner_subscription_/) do |_|
        partner_subscription_text
      end

      paragraph.substitute_across_runs_with_block(/_partner_total_quotes_/) do |_|
        partner_total_quotes_text
      end

      paragraph.substitute_across_runs_with_block(/_partner_sum_/) do |_|
        partner_sum_text
      end

      paragraph.substitute_across_runs_with_block(/_%_/) do |_|
        percentage_text
      end

      paragraph.substitute_across_runs_with_block(/_total_quotes_/) do |_|
        format_number(total_quotes)
      end

      paragraph.substitute_across_runs_with_block(/_sum_percentage_/) do |_|
        '100%'
      end

      # Signature fields for partners 1 and 2
      paragraph.substitute_across_runs_with_block(/_partner_1_full_name_/) do |_|
        lawyers[0] ? lawyer_full_name(lawyers[0]) : ''
      end

      paragraph.substitute_across_runs_with_block(/_parner_1_association_/) do |_|
        lawyers[0] ? lawyer_association(lawyers[0]) : ''
      end

      paragraph.substitute_across_runs_with_block(/_partner_2_full_name_/) do |_|
        lawyers[1] ? lawyer_full_name(lawyers[1]) : ''
      end

      paragraph.substitute_across_runs_with_block(/_partner_2_association_/) do |_|
        lawyers[1] ? lawyer_association(lawyers[1]) : ''
      end

      handle_numbered_partner_fields(paragraph)

      # Handle typo version
      paragraph.substitute_across_runs_with_block(/_parner_full_name_/) do |_|
        partner_full_name_text
      end
    end

    def substitute_capital_fields(paragraph)
      # Already handled in office fields
    end

    def substitute_pro_labore_dividends_clauses(paragraph)
      paragraph.substitute_across_runs_with_block(/(?<![_\w])_pro_labore_(?![_\w])/) do |_|
        pro_labore_enabled? ? 'Parágrafo Sétimo:' : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_pro_labore_text_(?![_\w])/) do |_|
        pro_labore_enabled? ? pro_labore_text : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_dividends_(?![_\w])/) do |_|
        dividends_enabled? ? 'Parágrafo Terceiro:' : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_dividends_text_(?![_\w])/) do |_|
        dividends_enabled? ? dividends_text : ''
      end
    end

    def substitute_date_field(paragraph)
      paragraph.substitute_across_runs_with_block(/(?<![_\w])_date_(?![_\w])/) do |_|
        formatted_date
      end
    end

    def handle_numbered_partner_fields(paragraph)
      lawyers.each_with_index do |lawyer, index|
        next if index.zero? # First partner uses non-numbered placeholders

        partner_num = index + 1

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_partner_full_name_#{partner_num}_(?![_\w])/) do |_|
          lawyer_full_name(lawyer)
        end

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_partner_total_quotes_#{partner_num}_(?![_\w])/) do |_|
          format_number(lawyer_quotes(lawyer))
        end

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_parner_total_quotes_#{partner_num}_(?![_\w])/) do |_|
          format_number(lawyer_quotes(lawyer))
        end

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_partner_sum_#{partner_num}_(?![_\w])/) do |_|
          format_currency(lawyer_capital_value(lawyer))
        end

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_%_#{partner_num}_(?![_\w])/) do |_|
          "#{lawyer_percentage(lawyer)}%"
        end
      end

      # Handle signature fields for partners 3+
      (3..lawyers.size).each do |partner_num|
        lawyer = lawyers[partner_num - 1]
        next unless lawyer

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_partner_#{partner_num}_full_name_(?![_\w])/) do |_|
          lawyer_full_name(lawyer)
        end

        paragraph.substitute_across_runs_with_block(/(?<![_\w])_parner_#{partner_num}_association_(?![_\w])/) do |_|
          lawyer_association(lawyer)
        end
      end
    end

    def add_partner_rows_to_tables
      doc.tables.each do |table|
        partner_row_index = find_partner_row(table)

        add_capital_table_rows(table, partner_row_index) if partner_row_index

        signature_row_index = find_signature_row(table)

        add_signature_table_rows(table, signature_row_index) if signature_row_index && lawyers.size > 2
      end
    end

    def find_partner_row(table)
      table.rows.each_with_index do |row, index|
        row_text = row.cells.map do |cell|
          cell.paragraphs.map(&:to_s).join(' ')
        end.join(' ')

        if row_text.include?('_partner_full_name_') ||
           row_text.include?('_partner_total_quotes_') ||
           row_text.include?('_partner_sum_')
          return index
        end
      end
      nil
    end

    def find_signature_row(table)
      table.rows.each_with_index do |row, index|
        row_text = row.cells.map do |cell|
          cell.paragraphs.map(&:to_s).join(' ')
        end.join(' ')

        if row_text.include?('_partner_1_full_name_') ||
           row_text.include?('_partner_2_full_name_')
          return index
        end
      end
      nil
    end

    def add_capital_table_rows(table, partner_row_index)
      partner_row = table.rows[partner_row_index]
      partner_row_node = partner_row.node

      num_rows_to_add = lawyers.size - 1
      last_inserted = partner_row_node

      num_rows_to_add.times do |i|
        partner_number = i + 2
        new_row = partner_row_node.dup

        cells = new_row.xpath('.//w:tc')
        cells.each do |cell|
          cell.xpath('.//w:p').each do |p_node|
            temp_paragraph = ::Docx::Elements::Containers::Paragraph.new(p_node, {}, nil)
            update_row_placeholders(temp_paragraph, partner_number)
          end
        end

        last_inserted.add_next_sibling(new_row)
        last_inserted = new_row
      end
    end

    def add_signature_table_rows(table, signature_row_index)
      signature_row = table.rows[signature_row_index]
      signature_row_node = signature_row.node

      partners_to_add = lawyers.size - 2
      num_signature_rows_to_add = (partners_to_add + 1) / 2

      last_inserted = signature_row_node

      num_signature_rows_to_add.times do |row_num|
        new_row = signature_row_node.dup

        first_partner_num = 3 + (row_num * 2)
        second_partner_num = first_partner_num + 1

        cells = new_row.xpath('.//w:tc')
        cells.each_with_index do |cell, cell_idx|
          cell.xpath('.//w:p').each do |p_node|
            temp_paragraph = ::Docx::Elements::Containers::Paragraph.new(p_node, {}, nil)
            update_signature_row_placeholders(temp_paragraph, cell_idx, first_partner_num, second_partner_num)
          end
        end

        last_inserted.add_next_sibling(new_row)
        last_inserted = new_row
      end
    end

    def update_row_placeholders(paragraph, partner_number)
      paragraph.substitute_across_runs_with_block(/_partner_full_name_/) do |_|
        "_partner_full_name_#{partner_number}_"
      end

      paragraph.substitute_across_runs_with_block(/_partner_total_quotes_/) do |_|
        "_partner_total_quotes_#{partner_number}_"
      end

      paragraph.substitute_across_runs_with_block(/_parner_total_quotes_/) do |_|
        "_parner_total_quotes_#{partner_number}_"
      end

      paragraph.substitute_across_runs_with_block(/_partner_sum_/) do |_|
        "_partner_sum_#{partner_number}_"
      end

      paragraph.substitute_across_runs_with_block(/_%_/) do |_|
        "_%_#{partner_number}_"
      end
    end

    def update_signature_row_placeholders(paragraph, cell_idx, first_partner_num, second_partner_num)
      if cell_idx.zero?
        paragraph.substitute_across_runs_with_block(/_partner_1_full_name_/) do |_|
          "_partner_#{first_partner_num}_full_name_"
        end
        paragraph.substitute_across_runs_with_block(/_parner_1_association_/) do |_|
          "_parner_#{first_partner_num}_association_"
        end
      elsif cell_idx == 1 && second_partner_num <= lawyers.size
        paragraph.substitute_across_runs_with_block(/_partner_2_full_name_/) do |_|
          "_partner_#{second_partner_num}_full_name_"
        end
        paragraph.substitute_across_runs_with_block(/_partner_2_association_/) do |_|
          "_parner_#{second_partner_num}_association_"
        end
      end
    end

    # Helper methods for data extraction - delegated to office_formatter
    def office_name
      office_formatter.office_name
    end

    def office_city
      office_formatter.office_city
    end

    def office_state
      office_formatter.office_state
    end

    def office_street
      office_formatter.office_street
    end

    def office_zip_code
      office_formatter.office_zip_code
    end

    def partner_qualification_text
      if lawyers.size == 2
        "#{Formatter.build(lawyers[0]).qualification} e #{Formatter.build(lawyers[1]).qualification}"
      else
        lawyers.map { |l| Formatter.build(l).qualification }.join('; ')
      end
    end

    def partner_full_name_text
      admin_lawyer = office_formatter.find_administrator_lawyer
      if admin_lawyer
        Formatter.build(admin_lawyer).full_name
      else
        lawyers.map { |l| Formatter.build(l).full_name }.join(' e ')
      end
    end

    def partner_subscription_text
      office_formatter.partner_subscription_text
    end

    def partner_total_quotes_text
      office_formatter.partner_total_quotes_text
    end

    def partner_sum_text
      office_formatter.partner_sum_text
    end

    def percentage_text
      office_formatter.percentage_text
    end

    def lawyer_full_name(lawyer)
      Formatter.build(lawyer).full_name
    end

    def lawyer_association(lawyer)
      office_formatter.lawyer_association(lawyer)
    end

    def lawyer_quotes(lawyer)
      office_formatter.lawyer_quotes(lawyer)
    end

    def lawyer_capital_value(lawyer)
      office_formatter.lawyer_capital_value(lawyer)
    end

    def lawyer_percentage(lawyer)
      office_formatter.lawyer_percentage(lawyer)
    end

    def total_capital_value
      office_formatter.total_capital_value
    end

    def total_quotes
      office_formatter.total_quotes
    end

    def quote_value
      office_formatter.quote_value
    end

    def pro_labore_enabled?
      office_formatter.pro_labore_enabled?
    end

    def pro_labore_text
      office_formatter.pro_labore_text
    end

    def dividends_enabled?
      office_formatter.dividends_enabled?
    end

    def dividends_text
      office_formatter.dividends_text
    end

    def format_currency(value)
      office_formatter.send(:format_currency, value)
    end

    def format_number(value)
      office_formatter.send(:format_number, value)
    end

    def formatted_date
      today = Time.zone.now
      months = [
        'janeiro',
        'fevereiro',
        'março',
        'abril',
        'maio',
        'junho',
        'julho',
        'agosto',
        'setembro',
        'outubro',
        'novembro',
        'dezembro'
      ]
      "#{today.day} de #{months[today.month - 1]} de #{today.year}"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
