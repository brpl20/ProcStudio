# frozen_string_literal: true

require 'docx'

module DocxServices
  class SocialContractServiceUnipessoal < BaseTemplate
    attr_reader :office_formatter, :partner_formatter, :doc, :file_path

    def initialize(*args)
      super
      @office_formatter = FormatterOffices.for_office(office, lawyers)
      @partner_formatter = FormatterQualification.for(lawyers.first) if lawyers.any?
    end

    # Define which fields will be used in the document
    def fields
      {
        # Office fields
        office_name: office_formatter.office_name,
        office_city: office_formatter.office_city,
        office_state: office_formatter.office_state,
        office_address: office_formatter.office_street,
        office_zip_code: office_formatter.office_zip_code,
        office_full_address: office_formatter.office_full_address,

        # Capital and quotes fields
        office_total_value: format_currency(office_formatter.total_capital_value),
        office_quotes: format_number(office_formatter.total_quotes),
        office_quote_value: "#{office_formatter.quote_value.to_i},00",

        # Partner fields (single partner for unipessoal)
        partner_qualification: partner_formatter&.qualification,
        partner_full_name: partner_formatter&.full_name(upcase: true),
        partner_name: partner_formatter&.full_name,
        partner_cpf: partner_formatter&.cpf,
        partner_rg: partner_formatter&.rg,
        partner_address: partner_formatter&.address,
        partner_email: partner_formatter&.email,
        partner_phone: partner_formatter&.phone,

        # Partner capital fields
        partner_subscription: format_currency(office_formatter.lawyer_capital_value(lawyers.first)),
        partner_total_quotes: format_number(office_formatter.lawyer_quotes(lawyers.first)),
        partner_sum: format_currency(office_formatter.lawyer_capital_value(lawyers.first)),
        partner_percentage: '100%',

        # Pro labore and dividends
        pro_labore_enabled: office_formatter.pro_labore_enabled?,
        pro_labore_text: office_formatter.pro_labore_text,
        dividends_enabled: office_formatter.dividends_enabled?,
        dividends_text: office_formatter.dividends_text,

        # Date
        date: formatted_date
      }
    end

    def process_document
      @doc = ::Docx::Document.open(template_path)
      @file_path = Rails.root.join('tmp', file_name)

      # Process all paragraphs in the document
      doc.paragraphs.each do |paragraph|
        substitute_placeholders(paragraph)
      end

      # Process all tables in the document
      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              substitute_placeholders(paragraph)
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
      "cs-unipessoal-#{office.name}.docx"
    end

    private

    def substitute_placeholders(paragraph)
      # Office fields
      paragraph.substitute_across_runs_with_block(/_office_name_/) do |_|
        fields[:office_name]
      end

      paragraph.substitute_across_runs_with_block(/_office_city_/) do |_|
        fields[:office_city]
      end

      paragraph.substitute_across_runs_with_block(/_office_state_/) do |_|
        fields[:office_state]
      end

      paragraph.substitute_across_runs_with_block(/_office_address_/) do |_|
        fields[:office_address]
      end

      paragraph.substitute_across_runs_with_block(/_office_zip_code_/) do |_|
        fields[:office_zip_code]
      end

      paragraph.substitute_across_runs_with_block(/_office_full_address_/) do |_|
        fields[:office_full_address]
      end

      # Capital and quotes fields
      paragraph.substitute_across_runs_with_block(/_office_total_value_/) do |_|
        fields[:office_total_value]
      end

      paragraph.substitute_across_runs_with_block(/_office_quotes_/) do |_|
        fields[:office_quotes]
      end

      paragraph.substitute_across_runs_with_block(/_office_quote_value_/) do |_|
        fields[:office_quote_value]
      end

      paragraph.substitute_across_runs_with_block(/_total_quotes_/) do |_|
        fields[:office_quotes]
      end

      # Partner qualification fields
      paragraph.substitute_across_runs_with_block(/_partner_qualification_/) do |_|
        fields[:partner_qualification]
      end

      paragraph.substitute_across_runs_with_block(/_partner_full_name_/) do |_|
        fields[:partner_full_name]
      end

      # Handle typo in template
      paragraph.substitute_across_runs_with_block(/_parner_full_name_/) do |_|
        fields[:partner_full_name]
      end

      paragraph.substitute_across_runs_with_block(/_partner_name_/) do |_|
        fields[:partner_name]
      end

      paragraph.substitute_across_runs_with_block(/_partner_cpf_/) do |_|
        fields[:partner_cpf]
      end

      paragraph.substitute_across_runs_with_block(/_partner_rg_/) do |_|
        fields[:partner_rg]
      end

      paragraph.substitute_across_runs_with_block(/_partner_address_/) do |_|
        fields[:partner_address]
      end

      paragraph.substitute_across_runs_with_block(/_partner_email_/) do |_|
        fields[:partner_email]
      end

      paragraph.substitute_across_runs_with_block(/_partner_phone_/) do |_|
        fields[:partner_phone]
      end

      # Partner capital fields
      paragraph.substitute_across_runs_with_block(/_partner_subscription_/) do |_|
        fields[:partner_subscription]
      end

      paragraph.substitute_across_runs_with_block(/_partner_total_quotes_/) do |_|
        fields[:partner_total_quotes]
      end

      paragraph.substitute_across_runs_with_block(/_partner_sum_/) do |_|
        fields[:partner_sum]
      end

      paragraph.substitute_across_runs_with_block(/_%_/) do |_|
        fields[:partner_percentage]
      end

      paragraph.substitute_across_runs_with_block(/_sum_percentage_/) do |_|
        fields[:partner_percentage]
      end

      # Partner 1 specific fields
      paragraph.substitute_across_runs_with_block(/_partner_1_full_name_/) do |_|
        fields[:partner_full_name]
      end

      paragraph.substitute_across_runs_with_block(/_parner_1_association_/) do |_|
        'Sócio Administrador'
      end

      # Empty partner 2 for single lawyer
      paragraph.substitute_across_runs_with_block(/_partner_2_full_name_/) do |_|
        ''
      end

      paragraph.substitute_across_runs_with_block(/_partner_2_association_/) do |_|
        ''
      end

      # Pro labore and dividends clauses
      paragraph.substitute_across_runs_with_block(/(?<![_\w])_pro_labore_(?![_\w])/) do |_|
        fields[:pro_labore_enabled] ? 'Parágrafo Sétimo:' : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_pro_labore_text_(?![_\w])/) do |_|
        fields[:pro_labore_enabled] ? fields[:pro_labore_text] : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_dividends_(?![_\w])/) do |_|
        fields[:dividends_enabled] ? 'Parágrafo Terceiro:' : ''
      end

      paragraph.substitute_across_runs_with_block(/(?<![_\w])_dividends_text_(?![_\w])/) do |_|
        fields[:dividends_enabled] ? fields[:dividends_text] : ''
      end

      # Date field
      paragraph.substitute_across_runs_with_block(/(?<![_\w])_date_(?![_\w])/) do |_|
        fields[:date]
      end
    end

    # Helper methods
    def format_currency(value)
      "#{value.to_i.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, '.')},00"
    end

    def format_number(value)
      value.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, '.')
    end

    def formatted_date
      today = Time.zone.now
      months = [
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
      ]
      "#{today.day} de #{months[today.month - 1]} de #{today.year}"
    end
  end
end
