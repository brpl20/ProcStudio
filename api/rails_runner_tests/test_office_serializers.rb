#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails runner test for Office serializers with new compensation features
# Usage: rails runner rails_runner_tests/test_office_serializers.rb

puts "=" * 60
puts "Testing Office Serializers with Compensation Features"
puts "=" * 60

# Find an office with user_offices and compensations
office = Office.joins(:user_offices).first

if office.nil?
  puts "ERROR: No office with user_offices found!"
  exit 1
end

puts "\nTesting Office: #{office.name} (ID: #{office.id})"
puts "Proportional: #{office.proportional}"
puts "User Offices count: #{office.user_offices.count}"

# Test basic OfficeSerializer (index view)
puts "\n" + "=" * 40
puts "Testing OfficeSerializer (Index View)"
puts "=" * 40

basic_serializer = OfficeSerializer.new(office, { params: { action: 'index' } })
basic_data = basic_serializer.serializable_hash

puts "\nBasic attributes included:"
basic_data[:data][:attributes].each do |key, value|
  puts "  #{key}: #{value.is_a?(String) && value.length > 50 ? value[0..47] + '...' : value}"
end

puts "\nProportional field present: #{basic_data[:data][:attributes].key?(:proportional)}"
puts "Proportional value: #{basic_data[:data][:attributes][:proportional]}"

# Test detailed OfficeSerializer (show view)
puts "\n" + "=" * 40
puts "Testing OfficeSerializer (Show View)"
puts "=" * 40

detailed_serializer = OfficeSerializer.new(office, { params: { action: 'show' } })
detailed_data = detailed_serializer.serializable_hash

puts "\nDetailed attributes:"
detailed_data[:data][:attributes].each do |key, value|
  case key
  when :user_offices
    puts "  #{key}: #{value.is_a?(Array) ? "Array with #{value.count} items" : value}"
    if value.is_a?(Array) && value.any?
      puts "    First user_office keys: #{value.first.keys.join(', ')}"
      if value.first[:compensations]
        puts "    Compensations: #{value.first[:compensations].count} items"
      end
    end
  when :partners_info
    puts "  #{key}: #{value.is_a?(Array) ? "Array with #{value.count} items" : value}"
  when :partners_compensation
    puts "  #{key}: #{value.is_a?(Array) ? "Array with #{value.count} items" : value}"
  when :is_proportional
    puts "  #{key}: #{value}"
  else
    display_value = if value.is_a?(String) && value.length > 50
                      value[0..47] + '...'
                    elsif value.is_a?(Array)
                      "Array with #{value.count} items"
                    else
                      value
                    end
    puts "  #{key}: #{display_value}"
  end
end

# Test OfficeWithLawyersSerializer
puts "\n" + "=" * 40
puts "Testing OfficeWithLawyersSerializer"
puts "=" * 40

lawyers_serializer = OfficeWithLawyersSerializer.new(office)
lawyers_data = lawyers_serializer.serializable_hash

puts "\nOfficeWithLawyers attributes:"
lawyers_data[:data][:attributes].each do |key, value|
  if key == :lawyers
    puts "  #{key}: Array with #{value.count} lawyers"
    value.each_with_index do |lawyer, index|
      puts "    Lawyer #{index + 1}:"
      puts "      Name: #{lawyer[:name]}"
      puts "      Partnership: #{lawyer[:partnership_type]} (#{lawyer[:partnership_percentage]}%)"
      puts "      Administrator: #{lawyer[:is_administrator]}"
      if lawyer[:current_compensation]
        puts "      Current Compensation: #{lawyer[:current_compensation][:compensation_type]} - #{lawyer[:current_compensation][:amount_formatted]}"
      else
        puts "      Current Compensation: None"
      end
      puts "      Total Compensations: #{lawyer[:all_compensations].count}"
    end
  else
    puts "  #{key}: #{value}"
  end
end

# Test UserSocietyCompensationSerializer directly if compensations exist
puts "\n" + "=" * 40
puts "Testing UserSocietyCompensationSerializer"
puts "=" * 40

compensation = UserSocietyCompensation.first
if compensation
  comp_serializer = UserSocietyCompensationSerializer.new(compensation)
  comp_data = comp_serializer.serializable_hash
  
  puts "\nCompensation serializer attributes:"
  comp_data[:data][:attributes].each do |key, value|
    puts "  #{key}: #{value}"
  end
else
  puts "\nNo compensations found in database"
end

# Test UserOfficeSerializer directly
puts "\n" + "=" * 40
puts "Testing UserOfficeSerializer"
puts "=" * 40

user_office = office.user_offices.first
if user_office
  uo_serializer = UserOfficeSerializer.new(user_office)
  uo_data = uo_serializer.serializable_hash
  
  puts "\nUserOffice serializer attributes:"
  uo_data[:data][:attributes].each do |key, value|
    if key == :compensations
      puts "  #{key}: Array with #{value.count} items"
      value.each_with_index do |comp, index|
        puts "    Compensation #{index + 1}: #{comp[:compensation_type]} - #{comp[:amount_formatted]}"
      end
    else
      puts "  #{key}: #{value}"
    end
  end
else
  puts "\nNo user_offices found"
end

puts "\n" + "=" * 60
puts "Serializer testing completed!"
puts "=" * 60