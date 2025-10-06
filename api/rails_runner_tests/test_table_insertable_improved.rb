#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for improved TableInsertable concern
# Usage: rails runner rails_runner_tests/test_table_insertable_improved.rb

puts "="*80
puts "Testing IMPROVED TableInsertable Concern"
puts "="*80

# Load the improved concern
puts "\n[SETUP] Loading improved TableInsertable concern..."
require 'docx'
load Rails.root.join('app', 'services', 'docx_services', 'concerns', 'table_insertable_improved.rb')

# Test with different offices to verify table insertion
TEST_OFFICES = [6, 7, 8].select { |id| Office.exists?(id) }

if TEST_OFFICES.empty?
  puts "✗ No test offices found. Please ensure offices with IDs 6, 7, or 8 exist."
  exit 1
end

puts "\n[TEST CONFIGURATION]"
puts "  Testing with offices: #{TEST_OFFICES.join(', ')}"
puts "  Template path: app/services/docx_services/templates/CS-TEMPLATE.docx"

# Create a test class to isolate TableInsertable testing
class TableInsertableTestService
  include DocxServices::Concerns::TableInsertable
  
  attr_reader :doc, :office, :test_results
  
  def initialize(office_id)
    @office = Office.find(office_id)
    @test_results = {}
    @template_path = Rails.root.join('app/services/docx_services/templates/CS-TEMPLATE.docx')
  end
  
  def run_tests
    puts "\n  Testing Office ##{office.id}: #{office.name}"
    puts "  Partners count: #{office.user_profiles.count}"
    
    return unless template_exists?
    
    test_table_insertion
    test_placeholder_increment
    test_error_handling
    
    @test_results
  end
  
  private
  
  def template_exists?
    if File.exist?(@template_path)
      puts "  ✓ Template found"
      true
    else
      puts "  ✗ Template not found at #{@template_path}"
      false
    end
  end
  
  def test_table_insertion
    puts "\n    [Table Insertion Test]"
    
    begin
      @doc = ::Docx::Document.open(@template_path.to_s)
      initial_table_count = @doc.tables.count
      
      if initial_table_count == 0
        puts "      ⚠ No tables found in template"
        @test_results[:table_insertion] = :no_tables
        return
      end
      
      first_table = @doc.tables.first
      initial_row_count = first_table.rows.count
      puts "      Initial rows in first table: #{initial_row_count}"
      
      # Create inserter
      inserter = DocxServices::Concerns::TableInsertable::TableInserter.new(
        @doc,
        entity_type: 'partner',
        placeholders: %w[_partner_name_1_ _partner_value_1_ _partner_percentage_1_]
      )
      
      # Insert rows if multiple partners
      partners_count = office.user_profiles.count
      if partners_count > 1
        rows_to_insert = partners_count - 1
        puts "      Inserting #{rows_to_insert} rows for #{partners_count} partners..."
        
        inserter.insert_blank_rows_with_placeholders(
          count: rows_to_insert,
          table_index: 0,
          after_row_index: 1
        )
        
        # Verify insertion
        new_row_count = @doc.tables.first.rows.count
        expected_count = initial_row_count + rows_to_insert
        
        if new_row_count == expected_count
          puts "      ✓ Successfully inserted #{rows_to_insert} rows"
          puts "      Final row count: #{new_row_count}"
          @test_results[:table_insertion] = :success
        else
          puts "      ✗ Row count mismatch. Expected: #{expected_count}, Got: #{new_row_count}"
          @test_results[:table_insertion] = :mismatch
        end
      else
        puts "      Single partner - no insertion needed"
        @test_results[:table_insertion] = :single_partner
      end
      
    rescue => e
      puts "      ✗ Error during table insertion: #{e.message}"
      @test_results[:table_insertion] = :error
    end
  end
  
  def test_placeholder_increment
    puts "\n    [Placeholder Increment Test]"
    
    begin
      @doc = ::Docx::Document.open(@template_path.to_s)
      
      inserter = DocxServices::Concerns::TableInsertable::TableInserter.new(
        @doc,
        entity_type: 'test',
        placeholders: %w[_test_1_ _value_1_]
      )
      
      # Test placeholder increment logic
      test_cases = [
        { input: "_test_1_", from: 1, to: 2, expected: "_test_2_" },
        { input: "_value_1_", from: 1, to: 3, expected: "_value_3_" },
        { input: "_other_5_", from: 1, to: 2, expected: "_other_5_" }
      ]
      
      all_passed = true
      test_cases.each do |test_case|
        result = inserter.send(:increment_placeholder, test_case[:input], test_case[:from], test_case[:to])
        if result == test_case[:expected]
          puts "      ✓ #{test_case[:input]} -> #{result}"
        else
          puts "      ✗ #{test_case[:input]} expected #{test_case[:expected]}, got #{result}"
          all_passed = false
        end
      end
      
      @test_results[:placeholder_increment] = all_passed ? :success : :failed
      
    rescue => e
      puts "      ✗ Error during placeholder test: #{e.message}"
      @test_results[:placeholder_increment] = :error
    end
  end
  
  def test_error_handling
    puts "\n    [Error Handling Test]"
    
    begin
      @doc = ::Docx::Document.open(@template_path.to_s)
      
      # Test with invalid parameters
      inserter = DocxServices::Concerns::TableInsertable::TableInserter.new(
        @doc,
        entity_type: 'error_test',
        placeholders: %w[_test_]
      )
      
      # Test invalid table index
      begin
        inserter.insert_blank_rows_with_placeholders(
          count: 1,
          table_index: 999,
          after_row_index: 0
        )
        puts "      ✗ Should have raised InvalidTableIndexError"
        @test_results[:error_handling] = :failed
      rescue DocxServices::Concerns::TableInsertable::InvalidTableIndexError => e
        puts "      ✓ Correctly raised InvalidTableIndexError: #{e.message}"
        @test_results[:error_handling] = :success
      end
      
      # Test invalid count
      begin
        inserter.insert_blank_rows_with_placeholders(
          count: 0,
          table_index: 0,
          after_row_index: 0
        )
        puts "      ✗ Should have raised ArgumentError for invalid count"
      rescue ArgumentError => e
        puts "      ✓ Correctly raised ArgumentError: #{e.message}"
      end
      
    rescue => e
      puts "      ✗ Error during error handling test: #{e.message}"
      @test_results[:error_handling] = :error
    end
  end
end

# Run tests for each office
all_results = {}

TEST_OFFICES.each do |office_id|
  begin
    test_service = TableInsertableTestService.new(office_id)
    all_results[office_id] = test_service.run_tests
  rescue => e
    puts "\n  ✗ Failed to test Office ##{office_id}: #{e.message}"
    all_results[office_id] = { error: e.message }
  end
end

# Summary
puts "\n"*2
puts "="*80
puts "[TEST RESULTS SUMMARY]"
puts "="*80

all_results.each do |office_id, results|
  office = Office.find(office_id)
  puts "\nOffice ##{office_id} (#{office.name}):"
  
  if results[:error]
    puts "  ✗ Test failed: #{results[:error]}"
  else
    results.each do |test_name, result|
      status = case result
               when :success then "✓"
               when :single_partner, :no_tables then "⚠"
               else "✗"
               end
      puts "  #{status} #{test_name.to_s.humanize}: #{result}"
    end
  end
end

# Overall status
puts "\n[OVERALL STATUS]"
success_count = all_results.values.count { |r| r[:table_insertion] == :success || r[:table_insertion] == :single_partner }
total_count = all_results.size

if success_count == total_count
  puts "✓ All tests completed successfully"
else
  puts "⚠ #{success_count}/#{total_count} offices tested successfully"
end

puts "\nTest completed at: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
puts "="*80