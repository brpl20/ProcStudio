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

      # Insert table rows for multiple partners
      insert_partner_table_rows

      # Replace placeholders in the document
      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

      # Replace numbered partner placeholders in tables
      # TEMPORARILY DISABLED FOR DEBUGGING
      # substitute_numbered_partner_placeholders

      # Save the document
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

    def insert_partner_table_rows
      partners = @office.user_profiles

      puts "\n🚀 Inserting partner table rows"
      puts "   Number of partners: #{partners.count}"
      puts "   Partner names: #{partners.map(&:name).join(', ')}"

      # Only insert rows if there are more than 1 partner
      if partners.count > 1
        # Define the placeholders that we'll be incrementing
        placeholders = [
          '_partner_full_name_1_',
          '_partner_total_quotes_1_',
          '_partner_sum_1_',
          '_%_1_'
        ]

        # Use the new TableInserter to add rows
        inserter = DocxServices::Concerns::TableInsertable::TableInserter.new(
          doc,
          entity_type: 'partner',
          placeholders: placeholders
        )

        # Insert additional rows for partners 2, 3, etc.
        # count is partners.count - 1 because we already have row 1 in the template
        inserter.insert_blank_rows_with_placeholders(
          count: partners.count - 1,
          table_index: 0,  # First table in the document
          after_row_index: 1  # Insert after the first row (which has _1_ placeholders)
        )

        puts "   ✅ Added #{partners.count - 1} new rows for additional partners"
      else
        puts "   ℹ️  Only 1 partner - no additional rows needed"
      end
    end

    def substitute_numbered_partner_placeholders
      partners = @office.user_profiles

      # Process table cells for numbered partner placeholders
      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              partners.each_with_index do |partner, index|
                partner_number = index + 1
                formatter = user_formatters[index]

                # Substitute each numbered placeholder
                paragraph.substitute_across_runs_with_block_regex("_partner_full_name_#{partner_number}_") do |_|
                  formatter.full_name || partner.name || ''
                end

                paragraph.substitute_across_runs_with_block_regex("_partner_total_quotes_#{partner_number}_") do |_|
                  # Calculate partner's share of quotes
                  total_quotes = @office.number_of_quotes || 0
                  partner_quotes = (total_quotes.to_f / partners.count).round
                  partner_quotes.to_s
                end

                paragraph.substitute_across_runs_with_block_regex("_partner_sum_#{partner_number}_") do |_|
                  # Calculate partner's share of value
                  total_value = @office.quote_value || 0
                  partner_value = total_value.to_f / partners.count
                  MonetaryValidator.format(partner_value)
                end

                paragraph.substitute_across_runs_with_block_regex("_%_#{partner_number}_") do |_|
                  # Calculate partner's percentage share
                  percentage = (100.0 / partners.count).round(2)
                  "#{percentage}%"
                end
              end
            end
          end
        end
      end
    end
  end
end
