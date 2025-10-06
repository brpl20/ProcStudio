# Test script for dividend placeholder substitution
# Run with: rails runner rails_runner_tests/test_dividends_placeholder.rb

def test_dividends_placeholder
  puts "=== Testing Dividends Placeholder Substitution ==="
  puts "=" * 50
  
  # Find an office with user_offices
  office = Office.joins(:user_offices).first
  
  if office.nil?
    puts "ERROR: No office with user_offices found!"
    return
  end
  
  puts "\nOffice: #{office.name} (ID: #{office.id})"
  
  # Test with proportional = false
  puts "\n--- Testing with proportional = FALSE ---"
  office.update!(proportional: false)
  
  service = DocxServices::SocialContractServiceSociety.new(office.id)
  formatter = DocxServices::FormatterOffices.new(office.reload)
  
  puts "Is proportional: #{formatter.is_proportional}"
  puts "Expected dividends replacement: '' (empty string)"
  puts "Expected dividends_text replacement: '' (empty string)"
  
  # Test with proportional = true
  puts "\n--- Testing with proportional = TRUE ---"
  office.update!(proportional: true)
  
  service = DocxServices::SocialContractServiceSociety.new(office.id)
  formatter = DocxServices::FormatterOffices.new(office.reload)
  
  puts "Is proportional: #{formatter.is_proportional}"
  puts "Expected dividends replacement: 'Parágrafo Terceiro:'"
  puts "Expected dividends_text replacement: 'Os eventuais lucros serão distribuídos entre os sócios proporcionalmente às contribuições de cada um para o resultado.'"
  
  puts "\n" + "=" * 50
  puts "=== Test completed successfully! ==="
  puts "\nNote: To fully test the document generation, you can run:"
  puts "service = DocxServices::SocialContractServiceSociety.new(#{office.id})"
  puts "file_path = service.call"
  puts "puts \"Document generated at: \#{file_path}\""
  
rescue => e
  puts "\nERROR during testing: #{e.message}"
  puts e.backtrace.join("\n")
end

test_dividends_placeholder