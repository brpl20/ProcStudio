# frozen_string_literal: true

require 'nokogiri'

module DocxServices
  module Concerns
    module TableInsertable
      extend ActiveSupport::Concern

      class TableNotFoundError < StandardError; end
      class InvalidTableIndexError < StandardError; end

      class TableInserter
        attr_reader :doc, :entity_type, :placeholders

        def initialize(doc, entity_type:, placeholders:)
          @doc = doc
          @entity_type = entity_type.to_s.presence || 'unknown'
          @placeholders = Array(placeholders)

          validate_initialization!
        end

        def insert_blank_rows_with_placeholders(count:, table_index:, after_row_index: 1)
          return if count.to_i <= 0

          validate_row_count!(count)
          validate_row_index!(after_row_index)

          table = find_table_or_raise(table_index)

          log_insertion(count, after_row_index)
          add_blank_rows_with_placeholders(table, count, after_row_index)
        end

        private

        def validate_initialization!
          raise ArgumentError, 'Document cannot be nil' if doc.nil?
          raise ArgumentError, 'Placeholders cannot be empty' if placeholders.empty?
        end

        def validate_row_count!(count)
          raise ArgumentError, 'Row count must be a positive integer' unless count.is_a?(Integer) && count.positive?
        end

        def validate_row_index!(index)
          raise ArgumentError, 'Row index must be a non-negative integer' unless index.is_a?(Integer) && index >= 0
        end

        def find_table_or_raise(table_index)
          tables = doc.tables

          if tables.empty?
            error_message = build_no_tables_error_message
            log_and_raise_error(TableNotFoundError, error_message)
          end

          validate_table_index!(table_index, tables.size)
          tables[table_index]
        end

        def validate_table_index!(index, table_count)
          unless index.is_a?(Integer) && index >= 0
            error_message = "Table index must be a non-negative integer. Got: #{index.inspect}"
            log_and_raise_error(InvalidTableIndexError, error_message)
          end

          return unless index >= table_count

          error_message = build_index_out_of_bounds_error_message(index, table_count)
          log_and_raise_error(InvalidTableIndexError, error_message)
        end

        def build_no_tables_error_message
          "No tables found in document for entity type: '#{entity_type}'. " \
            'Please ensure the document template contains at least one table.'
        end

        def build_index_out_of_bounds_error_message(requested_index, table_count)
          "Table index #{requested_index} is out of bounds. " \
            "Document contains #{table_count} table(s) (indices 0-#{table_count - 1}). " \
            "Entity type: '#{entity_type}'"
        end

        def log_and_raise_error(error_class, message)
          Rails.logger.error "[TableInsertable] #{message}"
          raise error_class, message
        end

        def log_insertion(count, after_row_index)
          Rails.logger.info "[TableInsertable] Adding #{count} row(s) with placeholders " \
                            "after row #{after_row_index} for entity type: '#{entity_type}'"
        end

        def add_blank_rows_with_placeholders(table, count, after_index)
          return if count <= 0

          # Access the table's rows through the Docx API
          rows = table.rows
          return if rows.empty? || after_index >= rows.length

          reference_row = rows[after_index]
          reference_row_node = reference_row.node
          last_inserted_row = reference_row_node

          base_index = extract_base_index(reference_row_node)

          (base_index + 1..base_index + count).each do |new_index|
            new_row_node = create_new_row_with_placeholders(reference_row_node, base_index, new_index)
            last_inserted_row.add_next_sibling(new_row_node)
            last_inserted_row = new_row_node
          end
        end

        def create_new_row_with_placeholders(reference_row_node, original_index, new_index)
          new_row_node = reference_row_node.dup

          cells = new_row_node.xpath('.//w:tc')
          cells.each_with_index do |cell, cell_idx|
            # Clear the cell content
            clear_cell_content(cell)

            # Simply insert the placeholder for this cell position
            if cell_idx < placeholders.length
              # Now with substitution enabled
              placeholder_text = increment_placeholder(placeholders[cell_idx], original_index, new_index)
              insert_text_in_cell(cell, placeholder_text)
            end
          end

          new_row_node
        end

        def clear_cell_content(cell)
          cell.xpath('.//w:t').each { |text_node| text_node.remove }
        end

        def insert_text_in_cell(cell, text)
          p_node = cell.at_xpath('.//w:p')
          return unless p_node

          # Create proper Nokogiri nodes with namespace
          run_node = p_node.document.create_element('r')
          run_node.namespace = p_node.namespace

          text_node = p_node.document.create_element('t')
          text_node.namespace = p_node.namespace
          text_node.content = text

          run_node.add_child(text_node)
          p_node.add_child(run_node)
        end

        def increment_placeholder(placeholder, original_index, new_index)
          placeholder.gsub(/_(\d+)_/) do
            current_number = Regexp.last_match(1).to_i
            if current_number == original_index
              "_#{new_index}_"
            else
              "_#{current_number}_"
            end
          end
        end

        def extract_base_index(row_node)
          text_content = row_node.xpath('.//w:t').map(&:content).join(' ')

          matches = text_content.scan(/_(\d+)_/)
          return 1 if matches.empty?

          matches.map { |m| m[0].to_i }.max
        end
      end
    end
  end
end
