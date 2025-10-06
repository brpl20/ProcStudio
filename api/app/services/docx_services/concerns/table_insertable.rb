# frozen_string_literal: true

module DocxServices
  module Concerns
    module TableInsertable
      extend ActiveSupport::Concern

      class TableInserter
        attr_reader :doc, :entity_type, :placeholders, :search_terms

        def initialize(doc, entity_type:, placeholders:, search_terms: nil)
          @doc = doc
          @entity_type = entity_type.to_s
          @placeholders = Array(placeholders)
          @search_terms = search_terms || default_search_terms
        end

        def insert_rows(count:, table_index: nil, find_by: nil)
          puts "\n🔍 Starting table row insertion..."
          puts "   Entity type: #{entity_type}"
          puts "   Number of entities: #{count}"
          puts "   Placeholders: #{placeholders.inspect}"
          puts "   Search terms: #{search_terms.inspect}"
          
          return if count <= 1 # No need to add rows if only 1 entity

          puts "\n📊 Looking for table..."
          puts "   Table index: #{table_index}" if table_index
          puts "   Find by: #{find_by}" if find_by
          
          table = find_table(table_index: table_index, find_by: find_by)
          if table
            puts "   ✅ Table found!"
          else
            puts "   ❌ Table NOT found!"
            return
          end

          puts "\n🔍 Looking for template row with search terms..."
          template_row = find_template_row(table)
          if template_row
            puts "   ✅ Template row found!"
            row_text = template_row.cells.flat_map { |c| c.paragraphs.map(&:to_s) }.join(' ')
            puts "   Row content preview: #{row_text[0..200]}..."
          else
            puts "   ❌ Template row NOT found!"
            return
          end

          puts "\n➕ Adding #{count - 1} new rows..."
          add_entity_rows(table, template_row, count - 1)
        end

        private

        def default_search_terms
          placeholders.map { |p| "_#{entity_type}_#{p}_" }
        end

        def find_table(table_index: nil, find_by: nil)
          if table_index
            puts "   Using table index #{table_index}"
            table = doc.tables[table_index]
            if table
              puts "   Found table at index #{table_index}"
              # Debug first few rows
              table.rows.first(2).each_with_index do |row, idx|
                row_text = row.cells.flat_map { |c| c.paragraphs.map(&:to_s) }.join(' | ')
                puts "   Row #{idx}: #{row_text[0..100]}..."
              end
            end
            table
          elsif find_by
            find_table_by_content(find_by)
          else
            find_table_with_placeholders
          end
        end

        def find_table_by_content(content)
          doc.tables.find do |table|
            table_text = extract_table_text(table)
            Array(content).any? { |term| table_text.include?(term) }
          end
        end

        def find_table_with_placeholders
          doc.tables.find do |table|
            table_text = extract_table_text(table)
            search_terms.any? { |term| table_text.include?(term) }
          end
        end

        def extract_table_text(table)
          table.rows.flat_map do |row|
            row.cells.flat_map do |cell|
              cell.paragraphs.map(&:to_s).join(' ')
            end
          end.join(' ')
        end

        def find_template_row(table)
          table.rows.find do |row|
            row_text = row.cells.flat_map do |cell|
              cell.paragraphs.map(&:to_s).join(' ')
            end.join(' ')

            search_terms.any? { |term| row_text.include?(term) }
          end
        end

        def add_entity_rows(table, template_row, num_rows_to_add)
          row_node = template_row.node
          last_inserted = row_node

          num_rows_to_add.times do |i|
            entity_number = i + 2 # Start from 2 (first entity uses original placeholders)
            puts "\n   🔄 Creating row for #{entity_type} #{entity_number}..."
            
            new_row = duplicate_and_update_row(row_node, entity_number)
            
            # Debug the new row content
            new_row_text = new_row.xpath('.//w:t').map(&:content).join(' ')
            puts "   New row content: #{new_row_text[0..150]}..."
            
            last_inserted.add_next_sibling(new_row)
            last_inserted = new_row

            puts "   ✅ Added row #{i + 1} with placeholders for #{entity_type} #{entity_number}"
          end
        end

        def duplicate_and_update_row(row_node, entity_number)
          new_row = row_node.dup

          # Update placeholders in each cell
          cells = new_row.xpath('.//w:tc')
          cells.each do |cell|
            update_cell_placeholders(cell, entity_number)
          end

          new_row
        end

        def update_cell_placeholders(cell, entity_number)
          # Direct XML text node replacement
          cell.xpath('.//w:t').each do |text_node|
            original_text = text_node.content
            
            # Replace each placeholder with numbered version
            placeholders.each do |placeholder|
              original = "_#{entity_type}_#{placeholder}_"
              replacement = "_#{entity_type}_#{placeholder}_#{entity_number}_"
              original_text = original_text.gsub(original, replacement)
            end
            
            # Also handle the percentage placeholder
            original_text = original_text.gsub('_%_', "_%_#{entity_number}_")
            
            text_node.content = original_text
          end
        end
      end

      # Main module method to be used in docx services
      def insert_table_rows(doc, entities:, entity_type:, placeholders: nil, **options)
        puts "\n📌 insert_table_rows called!"
        puts "   Entities class: #{entities.class}"
        puts "   Entities size: #{entities.size if entities.respond_to?(:size)}"
        
        # Convert to array if it's an ActiveRecord collection
        entities = entities.to_a if entities.respond_to?(:to_a)
        
        return unless entities.is_a?(Array) && entities.size > 1

        placeholders ||= default_placeholders_for(entity_type)
        puts "   Using placeholders: #{placeholders.inspect}"

        inserter = TableInserter.new(
          doc,
          entity_type: entity_type,
          placeholders: placeholders,
          search_terms: options[:search_terms]
        )

        inserter.insert_rows(
          count: entities.size,
          table_index: options[:table_index],
          find_by: options[:find_by]
        )
      end

      # Override this method in your service to define default placeholders
      def default_placeholders_for(entity_type)
        case entity_type.to_s
        when 'partner'
          %w[full_name total_quotes sum percentage number_of_quotes]
        when 'lawyer'
          %w[name oab_number oab_state email]
        when 'witness'
          %w[name cpf rg profession]
        else
          %w[name]
        end
      end

      # Convenience methods for common entity types
      def insert_partner_rows(doc, partners, **options)
        insert_table_rows(
          doc,
          entities: partners,
          entity_type: 'partner',
          **options
        )
      end

      def insert_lawyer_rows(doc, lawyers, **options)
        insert_table_rows(
          doc,
          entities: lawyers,
          entity_type: 'lawyer',
          **options
        )
      end

      def insert_witness_rows(doc, witnesses, **options)
        insert_table_rows(
          doc,
          entities: witnesses,
          entity_type: 'witness',
          **options
        )
      end
    end
  end
end
