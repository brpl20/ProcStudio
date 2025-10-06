# Test script for partners_compensation method
# Run with: rails runner rails_runner_tests/test_partners_compensation.rb

def test_partners_compensation
  puts "\n=== Testing Partners Compensation ==="
  puts "=" * 50
  
  # Find an office with user_offices
  office = Office.joins(:user_offices).first
  
  if office.nil?
    puts "ERROR: No office with user_offices found!"
    return
  end
  
  puts "\nOffice: #{office.name}"
  puts "Proportional setting: #{office.proportional}"
  puts "Quote value: #{office.quote_value}"
  puts "Number of quotes: #{office.number_of_quotes}"
  
  # Create formatter instance
  formatter = DocxServices::FormatterOffices.new(office)
  
  # Test is_proportional method
  puts "\n--- Testing is_proportional method ---"
  puts "Is proportional: #{formatter.is_proportional}"
  
  # Test partners_compensation method
  puts "\n--- Testing partners_compensation method ---"
  compensation_data = formatter.partners_compensation
  
  if compensation_data.empty?
    puts "No compensation data found"
  else
    compensation_data.each do |partner_comp|
      puts "\nPartner ##{partner_comp[:number]}:"
      puts "  Name: #{partner_comp[:lawyer_name]}"
      puts "  Partnership type: #{partner_comp[:partnership_type]}"
      puts "  Partnership percentage: #{partner_comp[:partnership_percentage]}"
      puts "  Is administrator: #{partner_comp[:is_administrator]}"
      puts "  Compensation type: #{partner_comp[:compensation_type] || 'None'}"
      puts "  Compensation amount: #{partner_comp[:compensation_amount_formatted] || 'None'}"
      puts "  Payment frequency: #{partner_comp[:payment_frequency] || 'None'}"
      
      if partner_comp[:all_compensations].any?
        puts "  All compensations:"
        partner_comp[:all_compensations].each do |comp|
          puts "    - Type: #{comp[:type]}, Amount: #{comp[:amount_formatted]}, Frequency: #{comp[:frequency]}"
        end
      end
    end
  end
  
  # Test partners_info to see how proportional affects calculations
  puts "\n--- Testing partners_info (with proportional check) ---"
  partners_info = formatter.partners_info
  
  partners_info.each do |partner|
    puts "\nPartner ##{partner[:number]}:"
    puts "  Partnership percentage: #{partner[:partnership_percentage]}"
    puts "  Partner quote value: #{partner[:partner_quote_value_formatted] || 'N/A (proportional is false)'}"
    puts "  Partner number of quotes: #{partner[:partner_number_of_quotes_formatted] || 'N/A (proportional is false)'}"
  end
  
  # Test partner_subscription
  puts "\n--- Testing partner_subscription ---"
  if office.user_offices.any?
    subscription = formatter.partner_subscription(lawyer_number: 1)
    if subscription
      puts "Partner 1 subscription:"
      puts subscription
    else
      puts "No subscription generated (proportional might be false)"
    end
  end
  
  # Test setting proportional to true and see the difference
  puts "\n--- Testing with proportional = true ---"
  office.update!(proportional: true)
  formatter_with_prop = DocxServices::FormatterOffices.new(office.reload)
  
  puts "Is proportional: #{formatter_with_prop.is_proportional}"
  
  partners_info_prop = formatter_with_prop.partners_info
  partners_info_prop.each do |partner|
    puts "\nPartner ##{partner[:number]}:"
    puts "  Partnership percentage: #{partner[:partnership_percentage]}"
    puts "  Partner quote value: #{partner[:partner_quote_value_formatted] || 'None'}"
    puts "  Partner number of quotes: #{partner[:partner_number_of_quotes_formatted] || 'None'}"
  end
  
  puts "\n" + "=" * 50
  puts "=== Test completed successfully! ==="
  
rescue => e
  puts "\nERROR during testing: #{e.message}"
  puts e.backtrace.join("\n")
end

test_partners_compensation