# frozen_string_literal: true

require 'nokogiri'

module DocxServices
  module Concerns
    module TableInsertable
      extend ActiveSupport::Concern

      class TableNotFoundError < StandardError; end
      class InvalidTableIndexError < StandardError; end

      class TableInserter
        PLACEHOLDER_PATTERN = /_(\d+)_/.freeze
        DEFAULT_BASE_INDEX = 1
        
        attr_reader :doc, :entity_type, :placeholders

        def initialize(doc, entity_type:, placeholders:)
          @doc = doc
          @entity_type = entity_type.to_s.presence || 'unknown'
          @placeholders = Array(placeholders)
          
          validate_initialization!
        end

        def insert_blank_rows_with_placeholders(count:, table_index:, after_row_index: 1)
          validate_params!(count: count, table_index: table_index, after_row_index: after_row_index)
          
          table = find_table_or_raise(table_index)
          
          log_insertion(count, after_row_index)
          add_blank_rows_with_placeholders(table, count, after_row_index)
        end

        private

        # Validation methods
        def validate_initialization!
          raise ArgumentError, "Document cannot be nil" if doc.nil?
          raise ArgumentError, "Placeholders cannot be empty" if placeholders.empty?
        end

        def validate_params!(count:, table_index:, after_row_index:)
          validate_integer_param!(:count, count, minimum: 1)
          validate_integer_param!(:table_index, table_index, minimum: 0)
          validate_integer_param!(:after_row_index, after_row_index, minimum: 0)
        end

        def validate_integer_param!(name, value, minimum:)
          unless value.is_a?(Integer) && value >= minimum
            raise ArgumentError, "#{name} must be an integer >= #{minimum}. Got: #{value.inspect}"
          end
        end

        # Table finding methods
        def find_table_or_raise(table_index)
          tables = doc.tables
          
          raise_if_no_tables(tables) if tables.empty?
          raise_if_invalid_index(table_index, tables.size)
          
          tables[table_index]
        end

        def raise_if_no_tables(tables)
          log_and_raise_error(
            TableNotFoundError,
            "No tables found in document for entity type: '#{entity_type}'"
          )
        end

        def raise_if_invalid_index(index, table_count)
          return if index < table_count
          
          log_and_raise_error(
            InvalidTableIndexError,
            "Table index #{index} is out of bounds (0-#{table_count - 1})"
          )
        end

        # Row manipulation methods
        def add_blank_rows_with_placeholders(table, count, after_index)
          rows = table.rows
          return if !valid_row_range?(rows, after_index)
          
          reference_node = rows[after_index].node
          base_index = extract_base_index(reference_node)
          
          insert_new_rows(reference_node, base_index, count)
        end

        def valid_row_range?(rows, index)
          !rows.empty? && index < rows.length
        end

        def insert_new_rows(reference_node, base_index, count)
          last_inserted = reference_node
          
          (1..count).each do |offset|
            new_row = create_row_with_incremented_placeholders(
              reference_node, 
              base_index, 
              base_index + offset
            )
            last_inserted.add_next_sibling(new_row)
            last_inserted = new_row
          end
        end

        def create_row_with_incremented_placeholders(template_node, from_index, to_index)
          new_row = template_node.dup
          
          process_row_cells(new_row, from_index, to_index)
          
          new_row
        end

        def process_row_cells(row_node, from_index, to_index)
          cells = row_node.xpath('.//w:tc')
          
          cells.each_with_index do |cell, idx|
            replace_cell_content(cell, idx, from_index, to_index)
          end
        end

        def replace_cell_content(cell, cell_index, from_index, to_index)
          clear_cell_content(cell)
          
          return unless cell_index < placeholders.length
          
          new_text = increment_placeholder(placeholders[cell_index], from_index, to_index)
          insert_text_in_cell(cell, new_text)
        end

        # XML manipulation methods
        def clear_cell_content(cell)
          cell.xpath('.//w:t').remove
        end
        
        def insert_text_in_cell(cell, text)
          paragraph = cell.at_xpath('.//w:p')
          return unless paragraph
          
          add_text_run_to_paragraph(paragraph, text)
        end

        def add_text_run_to_paragraph(paragraph, text)
          namespace = paragraph.namespace
          
          run = create_element(paragraph.document, 'r', namespace)
          text_node = create_element(paragraph.document, 't', namespace)
          text_node.content = text
          
          run.add_child(text_node)
          paragraph.add_child(run)
        end

        def create_element(document, name, namespace)
          element = document.create_element(name)
          element.namespace = namespace
          element
        end

        # Placeholder processing methods
        def increment_placeholder(placeholder, from_index, to_index)
          placeholder.gsub(PLACEHOLDER_PATTERN) do
            number = Regexp.last_match(1).to_i
            "_#{number == from_index ? to_index : number}_"
          end
        end
        
        def extract_base_index(row_node)
          text = row_node.xpath('.//w:t').map(&:content).join(' ')
          numbers = text.scan(PLACEHOLDER_PATTERN).map { |m| m[0].to_i }
          
          numbers.empty? ? DEFAULT_BASE_INDEX : numbers.max
        end

        # Logging methods
        def log_and_raise_error(error_class, message)
          Rails.logger.error "[TableInsertable] #{message}"
          raise error_class, message
        end

        def log_insertion(count, after_row_index)
          Rails.logger.info "[TableInsertable] Adding #{count} row(s) after row #{after_row_index}"
        end
      end
    end
  end
end