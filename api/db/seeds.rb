# frozen_string_literal: true

require 'faker'

# Set Faker locale
Faker::Config.locale = 'pt-BR'

# ==========================================
# SEED FACADE ARCHITECTURE
# ==========================================
class SeedsFacade
  # Define available seed modules
  SEED_MODULES = {
    teams_offices_users: 'Teams, Offices, and Users',
    law_areas: 'Law Areas',
    law_areas_powers: 'Law Area Powers',
    customers: 'Customers',
    works: 'Works',
    jobs: 'Jobs'
  }.freeze

  class << self
    def run!(except: [])
      puts '[SEED] Starting seed process with facade architecture...'
      puts '=' * 50
      
      # Parse exceptions from environment variable or parameter
      exceptions = parse_exceptions(except)
      
      if exceptions.any?
        puts "[INFO] Excluding modules: #{exceptions.join(', ')}"
        puts '=' * 50
      end
      
      begin
        ActiveRecord::Base.transaction do
          # Order matters for dependencies
          load_teams_offices_users unless exceptions.include?('teams_offices_users')
          load_law_areas unless exceptions.include?('law_areas')
          load_law_areas_powers unless exceptions.include?('law_areas_powers')
          load_customers unless exceptions.include?('customers')
          load_works unless exceptions.include?('works')
          load_jobs unless exceptions.include?('jobs')
          
          display_statistics(exceptions)
        end
        
        display_credentials unless exceptions.include?('teams_offices_users')
      rescue StandardError => e
        puts "[ERROR] Error during seed process: #{e.message}"
        puts e.backtrace.first(5)
        raise
      end
    end
    
    private
    
    def parse_exceptions(except_param)
      # Support both environment variable and parameter
      env_exceptions = ENV['EXCEPT']&.split(',')&.map(&:strip) || []
      param_exceptions = Array(except_param).map(&:to_s)
      
      # Combine and normalize
      all_exceptions = (env_exceptions + param_exceptions).uniq.map(&:downcase)
      
      # Validate exceptions
      invalid = all_exceptions - SEED_MODULES.keys.map(&:to_s)
      if invalid.any?
        puts "[WARNING] Invalid modules to exclude: #{invalid.join(', ')}"
        puts "[INFO] Valid modules: #{SEED_MODULES.keys.join(', ')}"
      end
      
      all_exceptions & SEED_MODULES.keys.map(&:to_s)
    end
    
    def load_teams_offices_users
      puts "\n[TEAMS] Loading Teams, Offices, and Users..."
      load Rails.root.join('db/seeds_teams_offices_users.rb')
      puts "  [OK] Teams, Offices, and Users loaded successfully"
    end
    
    def load_law_areas
      puts "\n[LAW] Loading Law Areas..."
      load Rails.root.join('db/seeds_law_areas.rb')
      puts "  [OK] Law Areas loaded successfully"
    end
    
    def load_law_areas_powers
      puts "\n[POWERS] Loading Law Area Powers..."
      load Rails.root.join('db/seeds_law_areas_powers.rb')
      puts "  [OK] Law Area Powers loaded successfully"
    end
    
    def load_customers
      puts "\n[CUSTOMERS] Loading Customers..."
      load Rails.root.join('db/seeds_customers.rb')
      puts "  [OK] Customers loaded successfully"
    end
    
    def load_works
      puts "\n[WORKS] Loading Works..."
      load Rails.root.join('db/seeds_works.rb')
      puts "  [OK] Works loaded successfully"
    end
    
    def load_jobs
      puts "\n[JOBS] Loading Jobs..."
      load Rails.root.join('db/seeds_jobs.rb')
      puts "  [OK] Jobs loaded successfully"
    end
    
    def display_statistics(exceptions = [])
      puts "\n" + '=' * 50
      puts '[OK] Seed completed successfully!'
      puts '[STATS] Database Statistics:'
      
      unless exceptions.include?('teams_offices_users')
        puts "  - Teams: #{Team.count}"
        puts "  - Offices: #{Office.count}"
        puts "  - Office Addresses: #{Address.where(addressable_type: 'Office').count}"
        puts "  - Office Phones: #{Phone.where(phoneable_type: 'Office').count}"
        puts "  - Office Emails: #{Email.where(emailable_type: 'Office').count}"
        puts "  - Office Bank Accounts: #{BankAccount.where(bankable_type: 'Office').count}"
        puts "  - Users: #{User.count}"
        puts "  - User Profiles: #{UserProfile.count}"
        puts "  - User Addresses: #{Address.where(addressable_type: 'UserProfile').count}"
        puts "  - User Emails: #{Email.where(emailable_type: 'UserProfile').count}"
        puts "  - User Bank Accounts: #{BankAccount.where(bankable_type: 'UserProfile').count}"
      end
      
      unless exceptions.include?('law_areas')
        puts "  - Law Areas: #{LawArea.count}"
      end
      
      unless exceptions.include?('law_areas_powers')
        puts "  - Powers: #{Power.count}"
      end
      
      unless exceptions.include?('customers')
        puts "  - Customers: #{Customer.count}"
        puts "  - Profile Customers: #{ProfileCustomer.count}"
        puts "  - Customer Addresses: #{Address.where(addressable_type: 'ProfileCustomer').count}"
        puts "  - Customer Phones: #{Phone.where(phoneable_type: 'ProfileCustomer').count}"
        puts "  - Customer Emails: #{Email.where(emailable_type: 'ProfileCustomer').count}"
        puts "  - Customer Bank Accounts: #{BankAccount.where(bankable_type: 'ProfileCustomer').count}"
      end
      
      unless exceptions.include?('works')
        puts "  - Works: #{Work.count}"
      end
      
      unless exceptions.include?('jobs')
        puts "  - Jobs: #{Job.count}"
      end
      
      puts '=' * 50
    end
    
    def display_credentials
      puts "\n[CREDENTIALS] Test Credentials:"
      puts 'Lawyers/Staff:'
      puts '  - Email: joao.prado@advocacia.com.br | Password: Password123!'
      puts '  - Email: maria.silva@advocacia.com.br | Password: Password123!'
      puts '  - Email: ana.secretaria@advocacia.com.br | Password: Password123!'
      puts "\nCustomers:"
      puts '  - Email: cliente1@gmail.com | Password: ClientPass123!'
      puts '  - Email: empresa@empresa.com.br | Password: ClientPass123!'
      puts '  - Email: cliente.menor@gmail.com | Password: ClientPass123!'
    end
  end
end

# ==========================================
# EXECUTION
# ==========================================
# Parse command line arguments or ENV variable
# Usage examples:
#   rails db:seed
#   rails db:seed EXCEPT=works
#   rails db:seed EXCEPT=works,jobs
#   EXCEPT=works rails db:seed
# 
# Or programmatically:
#   SeedsFacade.run!(except: ['works'])
#   SeedsFacade.run!(except: [:works, :jobs])

if ENV['EXCEPT']
  SeedsFacade.run!
else
  # Default behavior - run all seeds
  SeedsFacade.run!
end