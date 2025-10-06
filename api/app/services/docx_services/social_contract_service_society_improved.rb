# frozen_string_literal: true

require 'docx'
require_relative 'concerns/table_insertable_improved'

module DocxServices
  class SocialContractServiceSociety
    include Concerns::TableInsertable
    
    PARTNER_PLACEHOLDERS = %w[
      _partner_full_name_1_
      _partner_total_quotes_1_
      _partner_sum_1_
      _%_1_
    ].freeze
    
    FIRST_TABLE_INDEX = 0
    TEMPLATE_ROW_INDEX = 1
    
    attr_reader :office, :formatter_qualification, :formatter_office, :user_formatters, :doc, :file_path

    def initialize(office_id)
      @office = Office.find(office_id)
      @formatter_qualification = FormatterQualification.new(@office)
      @formatter_office = FormatterOffices.new(@office)
      @user_formatters = @office.user_profiles.map { |user| FormatterQualification.new(user) }
    end

    def call
      process_document
      file_path
    end

    def process_document
      @doc = ::Docx::Document.open(template_path.to_s)
      @file_path = Rails.root.join('app', 'services', 'docx_services', 'output', file_name)

      insert_partner_table_rows if multiple_partners?
      substitute_all_placeholders
      
      doc.save(file_path.to_s)
    end

    protected

    def template_path
      Rails.root.join('app/services/docx_services/templates/CS-TEMPLATE.docx')
    end

    def file_name
      "cs-#{@office.name.parameterize}.docx"
    end

    private

    # Partner row insertion
    def multiple_partners?
      partners.count > 1
    end

    def partners
      @partners ||= @office.user_profiles
    end

    def insert_partner_table_rows
      Rails.logger.info "Inserting rows for #{partners.count} partners"
      
      inserter = create_table_inserter
      inserter.insert_blank_rows_with_placeholders(
        count: partners.count - 1,
        table_index: FIRST_TABLE_INDEX,
        after_row_index: TEMPLATE_ROW_INDEX
      )
    end

    def create_table_inserter
      DocxServices::Concerns::TableInsertable::TableInserter.new(
        doc,
        entity_type: 'partner',
        placeholders: PARTNER_PLACEHOLDERS
      )
    end

    # Placeholder substitution
    def substitute_all_placeholders
      substitute_document_placeholders
      substitute_partner_table_placeholders
    end

    def substitute_document_placeholders
      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end
    end

    def substitute_placeholders_with_block(paragraph)
      substitute_partner_qualification(paragraph)
      substitute_office_qualification(paragraph)
      substitute_office_settings(paragraph)
      substitute_date_field(paragraph)
    end

    def substitute_partner_qualification(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_partner_qualification_') do |_|
        @user_formatters.map(&:qualification).join('; ')
      end

      paragraph.substitute_across_runs_with_block_regex('_partner_subscription_') do |_|
        @formatter_office.all_partners_subscription
      end
    end

    def substitute_office_qualification(paragraph)
      office_fields = {
        '_office_name_' => -> { @formatter_qualification.full_name },
        '_office_state_' => -> { @formatter_qualification.state || '' },
        '_office_city_' => -> { @formatter_qualification.city || '' },
        '_office_address_' => -> { @formatter_qualification.address(with_prefix: false) || '' },
        '_office_zip_code_' => -> { @formatter_qualification.zip_code || '' }
      }

      office_fields.each do |placeholder, value_proc|
        paragraph.substitute_across_runs_with_block_regex(placeholder) { |_| value_proc.call }
      end
    end

    def substitute_office_settings(paragraph)
      settings_fields = {
        '_office_total_value_' => -> { @formatter_office.quote_value || '' },
        '_office_quotes_' => -> { @formatter_office.number_of_quotes || '' },
        '_office_quote_value_' => -> { individual_quote_value },
        '_office_society_type_' => -> { @formatter_office.society || '' },
        '_office_accounting_type_' => -> { @formatter_office.accounting_type || '' }
      }

      settings_fields.each do |placeholder, value_proc|
        paragraph.substitute_across_runs_with_block_regex(placeholder) { |_| value_proc.call }
      end
    end

    def substitute_date_field(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_current_date_') do |_|
        I18n.l(Date.current, format: :long)
      end
    end

    def individual_quote_value
      return '' unless @office.quote_value && @office.number_of_quotes&.positive?

      individual_value = @office.quote_value / @office.number_of_quotes.to_f
      MonetaryValidator.format(individual_value)
    end

    # Partner table placeholders
    def substitute_partner_table_placeholders
      doc.tables.each do |table|
        process_table_for_partners(table)
      end
    end

    def process_table_for_partners(table)
      table.rows.each do |row|
        process_row_for_partners(row)
      end
    end

    def process_row_for_partners(row)
      row.cells.each do |cell|
        process_cell_for_partners(cell)
      end
    end

    def process_cell_for_partners(cell)
      cell.paragraphs.each do |paragraph|
        substitute_partner_data_in_paragraph(paragraph)
      end
    end

    def substitute_partner_data_in_paragraph(paragraph)
      partners.each_with_index do |partner, index|
        substitute_single_partner_data(paragraph, partner, index)
      end
    end

    def substitute_single_partner_data(paragraph, partner, index)
      partner_number = index + 1
      formatter = user_formatters[index]
      
      partner_substitutions(formatter, partner_number).each do |pattern, value|
        paragraph.substitute_across_runs_with_block_regex(pattern) { |_| value }
      end
    end

    def partner_substitutions(formatter, number)
      {
        "_partner_full_name_#{number}_" => formatter.full_name || '',
        "_partner_total_quotes_#{number}_" => calculate_partner_quotes.to_s,
        "_partner_sum_#{number}_" => format_partner_value,
        "_%_#{number}_" => calculate_partner_percentage
      }
    end

    def calculate_partner_quotes
      total = @office.number_of_quotes || 0
      (total.to_f / partners.count).round
    end

    def format_partner_value
      total = @office.quote_value || 0
      value = total.to_f / partners.count
      MonetaryValidator.format(value)
    end

    def calculate_partner_percentage
      percentage = (100.0 / partners.count).round(2)
      "#{percentage}%"
    end
  end
end