#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'date'
require_relative '../field_debugger'

class SocialContractDataTest
  def initialize
    @test_data = load_test_data
  end

  def load_test_data
    file_path = File.join(__dir__, 'test_data.json')
    JSON.parse(File.read(file_path), symbolize_names: true)
  end

  def run_field_mapping_test
    puts "\n========================================="
    puts 'SOCIAL CONTRACT DATA MAPPING TEST'
    puts '========================================='

    puts "\n📊 LOADED TEST DATA:"
    puts '-' * 40
    puts "Office Name: #{@test_data[:office][:name]}"
    puts "Office CNPJ: #{@test_data[:office][:cnpj]}"
    puts "Office City: #{@test_data[:office][:addresses_attributes][0][:city]}"
    puts "Office State: #{@test_data[:office][:addresses_attributes][0][:state]}"
    puts "Quote Value: #{@test_data[:office][:quote_value]}"
    puts "Number of Quotes: #{@test_data[:office][:number_of_quotes]}"
    puts "User Profiles Count: #{@test_data[:user_profiles].length}"

    puts "\n📋 FIELD MAPPING:"
    puts '-' * 40

    field_mappings = generate_field_mappings
    field_mappings.each do |field, value|
      puts "#{field.ljust(25)} => #{value}"
    end

    puts "\n🔍 RUNNING FIELD DEBUGGER ON TEMPLATE:"
    puts '-' * 40
    debugger = FieldDebugger.new('CS-TEMPLATE.docx')
    debugger.scan_document

    puts "\n✅ TEST COMPLETED"
    puts 'Use the field mappings above to replace values in CS-TEMPLATE.docx'
    puts '========================================='
  end

  private

  def generate_field_mappings
    office = @test_data[:office]
    address = office[:addresses_attributes][0]

    # Get user profiles for partners
    partners = @test_data[:user_profiles]
    admin_partner = partners.find { |p| office[:user_offices_attributes].find { |uo| uo[:user_id] == p[:user_id] && uo[:is_administrator] } }

    # Calculate total capital value
    total_value = office[:quote_value] * office[:number_of_quotes]

    # Build field mappings based on discovered fields from field_debugger
    {
      '_office_name_' => office[:name],
      '_office_city_' => address[:city],
      '_office_state_' => address[:state],
      '_office_address_' => "#{address[:street]}, #{address[:number]}, #{address[:neighborhood]}",
      '_office_zip_code_' => address[:zip_code],
      '_office_total_value_' => format_currency(total_value),
      '_office_quotes_' => office[:number_of_quotes].to_s,
      '_office_quote_value_' => format_currency(office[:quote_value]),
      '_partner_full_name_' => admin_partner ? "#{admin_partner[:name]} #{admin_partner[:last_name]}" : 'N/A',
      '_partner_qualification_' => build_partner_qualification(admin_partner),
      '_parner_total_quotes_' => calculate_partner_quotes(admin_partner).to_s,
      '_partner_sum_' => format_currency(calculate_partner_value(admin_partner)),
      '_percentage_' => calculate_partner_percentage(admin_partner),
      '_total_quotes_' => office[:number_of_quotes].to_s,
      '_sum_percentage_' => '100.00'
    }
  end

  def build_partner_qualification(partner)
    return 'N/A' unless partner

    birth_date = Date.parse(partner[:birth])
    address = partner[:addresses][0]

    "#{partner[:nationality].downcase}, #{partner[:civil_status].downcase}, " \
    "#{partner[:role]}, nascido em #{birth_date.strftime('%d/%m/%Y')}, " \
    "natural de #{address[:city]}/#{address[:state]}, " \
    "portador da Cédula de Identidade RG nº #{partner[:rg]}, " \
    "inscrito no CPF sob o nº #{partner[:cpf]}, " \
    "#{partner[:oab]}, " \
    "residente e domiciliado em #{address[:city]}/#{address[:state]}, " \
    "#{address[:street]}, #{address[:number]}, #{address[:complement]}, " \
    "#{address[:neighborhood]}, CEP #{address[:zip_code]}"
  end

  def calculate_partner_quotes(partner)
    return 0 unless partner

    office = @test_data[:office]
    user_office = office[:user_offices_attributes].find { |uo| uo[:user_id] == partner[:user_id] }
    return 0 unless user_office

    percentage = user_office[:partnership_percentage].to_f / 100
    (office[:number_of_quotes] * percentage).to_i
  end

  def calculate_partner_value(partner)
    return 0 unless partner

    quotes = calculate_partner_quotes(partner)
    quotes * @test_data[:office][:quote_value]
  end

  def calculate_partner_percentage(partner)
    return '0.00' unless partner

    office = @test_data[:office]
    user_office = office[:user_offices_attributes].find { |uo| uo[:user_id] == partner[:user_id] }
    return '0.00' unless user_office

    user_office[:partnership_percentage]
  end

  def format_currency(value)
    '%.2f' % value
  end
end

# Run the test
begin
  test = SocialContractDataTest.new
  test.run_field_mapping_test
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
end
