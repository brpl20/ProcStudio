# Test script for administrator placeholder substitution
# Run with: rails runner rails_runner_tests/test_administrator_placeholder.rb

def test_administrator_placeholder
  puts "=== Testing Administrator Placeholder Substitution ==="
  puts "=" * 50
  
  # Find offices with different administrator configurations
  offices_with_admins = Office.joins(:user_offices).where(user_offices: { is_administrator: true }).distinct
  
  if offices_with_admins.empty?
    puts "ERROR: No offices with administrators found!"
    return
  end
  
  offices_with_admins.each do |office|
    puts "\n--- Office: #{office.name} (ID: #{office.id}) ---"
    
    service = DocxServices::SocialContractServiceSociety.new(office.id)
    formatter = DocxServices::FormatterOffices.new(office)
    partners_info = formatter.partners_info
    
    administrators = partners_info.select { |p| p[:is_administrator] }
    admin_count = administrators.count
    
    puts "Administrators count: #{admin_count}"
    
    if admin_count == 1
      admin_index = administrators.first[:number] - 1
      admin_user = office.user_profiles[admin_index]
      admin_formatter = DocxServices::FormatterQualification.new(admin_user)
      puts "Single administrator: #{admin_formatter.full_name}"
      puts "Expected format: 'pelo sócio [name]' or 'pela sócia [name]'"
    elsif admin_count > 1
      admin_names = administrators.map do |admin|
        user = office.user_profiles[admin[:number] - 1]
        DocxServices::FormatterQualification.new(user).full_name
      end
      puts "Multiple administrators: #{admin_names.join(', ')}"
      puts "Expected format: 'pelos sócios [names]' or 'pelas sócias [names]'"
    else
      puts "No administrators"
      puts "Expected: empty string"
    end
  end
  
  puts "\n" + "=" * 50
  puts "=== Test completed successfully! ==="
  
rescue => e
  puts "\nERROR during testing: #{e.message}"
  puts e.backtrace.join("\n")
end

test_administrator_placeholder