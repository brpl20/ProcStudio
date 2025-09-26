# frozen_string_literal: true

require 'docx'

module DocxServices
  class SocialContractServiceUnipessoal < BaseTemplate
    attr_reader :office_formatter, :doc, :file_path

    def initialize(*args)
      super
      @office_formatter = FormatterOffices.for_office(office, lawyers)
    end

    def fields; end

    def formatters
      # QUALIFICATOR
      # OFFICE
    end

    def process_document
      @doc = ::Docx::Document.open(template_path)
      @file_path = Rails.root.join('tmp', file_name)

      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

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
      'tests/CS-TEMPLATE-INDIVIDUAL.docx'
    end

    def file_name
      "cs-#{office.name}.docx"
    end

    private

    def substitute_placeholders_with_block(paragraph)
      substitute_office_fields(paragraph)
      substitute_single_partner_fields(paragraph)
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

    def substitute_single_partner_fields(paragraph)
      lawyer = lawyers.first

      paragraph.substitute_across_runs_with_block(/_partner_qualification_/) do |_|
        Formatter.build(lawyer).qualification
      end

      paragraph.substitute_across_runs_with_block(/_partner_full_name_/) do |_|
        Formatter.build(lawyer).full_name
      end

      paragraph.substitute_across_runs_with_block(/_parner_full_name_/) do |_|
        Formatter.build(lawyer).full_name
      end

      paragraph.substitute_across_runs_with_block(/_partner_subscription_/) do |_|
        format_currency(lawyer_capital_value(lawyer))
      end

      paragraph.substitute_across_runs_with_block(/_partner_total_quotes_/) do |_|
        format_number(lawyer_quotes(lawyer))
      end

      paragraph.substitute_across_runs_with_block(/_partner_sum_/) do |_|
        format_currency(lawyer_capital_value(lawyer))
      end

      paragraph.substitute_across_runs_with_block(/_%_/) do |_|
        '100%'
      end

      paragraph.substitute_across_runs_with_block(/_total_quotes_/) do |_|
        format_number(total_quotes)
      end

      paragraph.substitute_across_runs_with_block(/_sum_percentage_/) do |_|
        '100%'
      end

      paragraph.substitute_across_runs_with_block(/_partner_1_full_name_/) do |_|
        lawyer_full_name(lawyer)
      end

      paragraph.substitute_across_runs_with_block(/_parner_1_association_/) do |_|
        lawyer_association(lawyer)
      end

      # Empty partner 2 for single lawyer
      paragraph.substitute_across_runs_with_block(/_partner_2_full_name_/) do |_|
        ''
      end

      paragraph.substitute_across_runs_with_block(/_partner_2_association_/) do |_|
        ''
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

    # Helper methods delegated to office_formatter
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
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
      ]
      "#{today.day} de #{months[today.month - 1]} de #{today.year}"
    end
  end
end
