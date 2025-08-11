namespace :system do
  desc "Setup default system settings for a given year"
  task :setup_settings, [:year] => :environment do |t, args|
    year = args[:year] || Date.current.year
    
    puts "Setting up system settings for year #{year}..."
    
    begin
      SystemSetting.setup_defaults_for_year(year.to_i)
      puts "✓ System settings created successfully for #{year}"
      
      # Display created settings
      settings = SystemSetting.where(year: year)
      settings.each do |setting|
        puts "  - #{setting.description}: R$ #{setting.value}"
      end
    rescue => e
      puts "✗ Error creating system settings: #{e.message}"
    end
  end
end