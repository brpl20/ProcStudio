# frozen_string_literal: true

require 'docx'
require_relative 'concerns/table_insertable'

module DocxServices
  class SocialContractServiceSociety
    include Concerns::TableInsertable
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

      # Test table row insertion
      test_partner_row_insertion

      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

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

    def substitute_placeholders_with_block(paragraph)
      substitute_partner_qualification(paragraph)
      substitute_office_qualification(paragraph)
      substitute_office_settings(paragraph)
      substitute_date_field(paragraph)
    end

    def substitute_partner_qualification(paragraph)
      # Replace single placeholder with all partners' qualifications
      paragraph.substitute_across_runs_with_block_regex('_partner_qualification_') do |_|
        @user_formatters.map(&:qualification).join('; ')
      end

      paragraph.substitute_across_runs_with_block_regex('_partner_subscription_') do |_|
        @formatter_office.all_partners_subscription
      end
    end

    def substitute_office_qualification(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_office_name_') do |_|
        @formatter_qualification.full_name
      end

      paragraph.substitute_across_runs_with_block_regex('_office_state_') do |_|
        @formatter_qualification.state || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_city_') do |_|
        @formatter_qualification.city || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_address_') do |_|
        @formatter_qualification.address(with_prefix: false) || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_zip_code_') do |_|
        @formatter_qualification.zip_code || ''
      end
    end

    def substitute_office_settings(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_office_total_value_') do |_|
        @formatter_office.quote_value || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_quotes_') do |_|
        @formatter_office.number_of_quotes || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_quote_value_') do |_|
        individual_quote_value
      end

      paragraph.substitute_across_runs_with_block_regex('_office_society_type_') do |_|
        @formatter_office.society || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_accounting_type_') do |_|
        @formatter_office.accounting_type || ''
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

    def test_partner_row_insertion
      partners = @office.user_profiles
      
      puts "\n🚀 test_partner_row_insertion called!"
      puts "   Number of partners: #{partners.count}"
      puts "   Partner names: #{partners.map(&:name).join(', ')}"
      
      # Minimal test - just insert the rows
      insert_table_rows(
        doc,
        entities: partners,
        entity_type: 'partner',
        table_index: 0,
        placeholders: %w[full_name total_quotes sum]
      )
      
      puts "   ✅ test_partner_row_insertion finished!"
    end
  end
end
