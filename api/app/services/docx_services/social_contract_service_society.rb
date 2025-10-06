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

      # STEP 1: Insert table rows for multiple partners (creates _2_, _3_, etc. placeholders)
      insert_partner_table_rows

      # STEP 2: Insert table rows for signatures (creates _3_, _4_, etc. placeholders if > 2 partners)
      insert_signature_table_rows

      # STEP 3: Replace general placeholders in the document
      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

      # STEP 4: Replace General Table placeholders (that do not include the index)
      substitute_general_table_placeholders

      # STEP 5: Replace numbered partner placeholders in table:0
      substitute_numbered_partner_placeholders

      # STEP 6: Replace Signature placeholders in table:1
      substitute_signature_placeholders

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

      # Only insert rows if there are more than 1 partner
      return unless partners.count > 1

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
        table_index: 0, # First table in the document
        after_row_index: 1 # Insert after the first row (which has _1_ placeholders)
      )
    end

    def substitute_numbered_partner_placeholders
      partners = @office.user_profiles
      partners_info = @formatter_office.partners_info

      # Process table cells for numbered partner placeholders
      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              partners.each_with_index do |partner, index|
                partner_number = index + 1
                formatter = user_formatters[index]
                partner_info = partners_info.find { |pi| pi[:number] == partner_number }

                # Substitute each numbered placeholder
                paragraph.substitute_across_runs_with_block_regex("_partner_full_name_#{partner_number}_") do |_|
                  formatter.full_name || partner.name || ''
                end

                paragraph.substitute_across_runs_with_block_regex("_partner_total_quotes_#{partner_number}_") do |_|
                  # Use the actual partner's number of quotes from partners_info
                  partner_info ? partner_info[:partner_number_of_quotes_formatted] : ''
                end

                paragraph.substitute_across_runs_with_block_regex("_partner_sum_#{partner_number}_") do |_|
                  # Use the actual partner's quote value from partners_info
                  partner_info ? partner_info[:partner_quote_value_formatted] : ''
                end

                paragraph.substitute_across_runs_with_block_regex("_%_#{partner_number}_") do |_|
                  # Use the actual partner's percentage from partners_info
                  partner_info ? partner_info[:partnership_percentage] : ''
                end
              end
            end
          end
        end
      end
    end

    def insert_signature_table_rows
      partners = @office.user_profiles

      # Signature table already has placeholders for 2 partners in the first row
      # Only insert rows if there are more than 2 partners
      return unless partners.count > 2

      # Get the signature table (second table, index 1)
      return unless doc.tables.size > 1

      signature_table = doc.tables[1]

      # Find the row with signature placeholders
      signature_row_index = nil
      signature_table.rows.each_with_index do |row, idx|
        row_text = row.cells.map do |cell|
          cell.paragraphs.map(&:text).join(' ')
        end.join(' ')

        if row_text.include?('_partner_1_full_name_') || row_text.include?('_partner_2_full_name_')
          signature_row_index = idx
          break
        end
      end

      return unless signature_row_index

      signature_row = signature_table.rows[signature_row_index]
      signature_row_node = signature_row.node

      # Calculate how many new rows we need (2 partners per row)
      partners_to_add = partners.count - 2 # Subtract the 2 already in template
      num_signature_rows_to_add = (partners_to_add + 1) / 2 # Round up for odd numbers

      Rails.logger.info "[Signature Table] Adding #{num_signature_rows_to_add} rows for #{partners_to_add} additional partners"

      # Duplicate and modify each row
      last_inserted = signature_row_node
      num_signature_rows_to_add.times do |row_num|
        # Duplicate the row
        new_row = signature_row_node.dup
        
        # Calculate which partner numbers this row will handle
        first_partner_num = 3 + (row_num * 2)  # Partners 3, 5, 7...
        second_partner_num = first_partner_num + 1  # Partners 4, 6, 8...
        
        # Process each cell in the new row
        cells = new_row.xpath('.//w:tc')
        cells.each_with_index do |cell, cell_idx|
          # Create temporary paragraph objects to use substitute method
          cell.xpath('.//w:p').each do |p_node|
            temp_paragraph = Docx::Elements::Containers::Paragraph.new(p_node, {}, nil)
            
            if cell_idx == 0
              # First cell - replace partner_1 with odd numbered partners (3, 5, 7...)
              temp_paragraph.substitute_across_runs_with_block_regex('_partner_1_full_name_') do |_|
                "_partner_#{first_partner_num}_full_name_"
              end
              temp_paragraph.substitute_across_runs_with_block_regex('_partner_1_association_') do |_|
                "_partner_#{first_partner_num}_association_"
              end
            elsif cell_idx == 1
              # Second cell - handle even numbered partners (4, 6, 8...)
              if second_partner_num <= partners.count
                # Replace partner_2 with the even numbered partner
                temp_paragraph.substitute_across_runs_with_block_regex('_partner_2_full_name_') do |_|
                  "_partner_#{second_partner_num}_full_name_"
                end
                temp_paragraph.substitute_across_runs_with_block_regex('_partner_2_association_') do |_|
                  "_partner_#{second_partner_num}_association_"
                end
              else
                # Clear placeholders if no partner for this position
                temp_paragraph.substitute_across_runs_with_block_regex('_partner_2_full_name_') do |_|
                  ""
                end
                temp_paragraph.substitute_across_runs_with_block_regex('_partner_2_association_') do |_|
                  ""
                end
              end
            end
          end
        end
        
        # Add the modified row after the last inserted row
        last_inserted.add_next_sibling(new_row)
        last_inserted = new_row
        
        Rails.logger.info "[Signature Table] Added row #{row_num + 1} with placeholders for partners #{first_partner_num}" + 
                         (second_partner_num <= partners.count ? " and #{second_partner_num}" : "")
      end
    end

    def substitute_general_table_placeholders
      # Replace _total_quotes_ placeholder in all tables
      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              paragraph.substitute_across_runs_with_block_regex('_total_quotes_') do |_|
                @office.number_of_quotes.to_s
              end
            end
          end
        end
      end
    end

    def substitute_signature_placeholders
      partners = @office.user_profiles
      partners_info = @formatter_office.partners_info

      # Get the signature table (second table, index 1)
      return unless doc.tables.size > 1

      signature_table = doc.tables[1]

      signature_table.rows.each_with_index do |row, row_idx|
        row.cells.each_with_index do |cell, cell_idx|
          cell.paragraphs.each do |paragraph|
            # Calculate which partner this cell represents
            # Row 0, Cell 0 = Partner 1
            # Row 0, Cell 1 = Partner 2
            # Row 1, Cell 0 = Partner 3
            # Row 1, Cell 1 = Partner 4, etc.
            partner_position = (row_idx * 2) + cell_idx + 1

            # Only process if we have a partner for this position
            next unless partner_position <= partners.count

            partner = partners[partner_position - 1]
            formatter = user_formatters[partner_position - 1]
            partner_info = partners_info.find { |pi| pi[:number] == partner_position }

            # Replace name placeholder
            paragraph.substitute_across_runs_with_block_regex("_partner_#{partner_position}_full_name_") do |_|
              formatter.full_name || partner.name || ''
            end

            # Replace association placeholder (using partnership_type from partners_info)
            paragraph.substitute_across_runs_with_block_regex("_partner_#{partner_position}_association_") do |_|
              partner_info ? partner_info[:partnership_type] : 'Sócio'
            end
          end
        end
      end
    end
  end
end
