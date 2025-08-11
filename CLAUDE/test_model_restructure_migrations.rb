#!/usr/bin/env ruby
# Test script for model restructuring migrations
# Run this script to test the migrations and their rollback capability

require 'colorize'

def run_command(command, description)
  puts "\n#{description}...".yellow
  result = system(command)
  if result
    puts "✓ #{description} completed successfully".green
  else
    puts "✗ #{description} failed".red
    exit(1)
  end
  result
end

def check_table_exists(table_name)
  result = `rails runner "puts ActiveRecord::Base.connection.table_exists?('#{table_name}')"`
  result.strip == "true"
end

def check_column_exists(table_name, column_name)
  result = `rails runner "puts ActiveRecord::Base.connection.column_exists?('#{table_name}', '#{column_name}')"`
  result.strip == "true"
end

puts "=" * 80
puts "Model Restructuring Migration Test".cyan.bold
puts "=" * 80

# Step 1: Check current database state
puts "\n1. Checking current database state...".cyan
run_command("rails db:migrate:status | tail -10", "Current migration status")

# Step 2: Run the migrations
puts "\n2. Running migrations...".cyan
run_command("rails db:migrate", "Running all pending migrations")

# Step 3: Verify new tables exist
puts "\n3. Verifying new tables...".cyan
if check_table_exists("legal_entity_offices")
  puts "✓ legal_entity_offices table exists".green
else
  puts "✗ legal_entity_offices table missing".red
  exit(1)
end

if check_table_exists("legal_entity_office_relationships")
  puts "✓ legal_entity_office_relationships table exists".green
else
  puts "✗ legal_entity_office_relationships table missing".red
  exit(1)
end

# Step 4: Verify polymorphic columns on customers
puts "\n4. Verifying polymorphic columns on customers...".cyan
if check_column_exists("customers", "profile_type")
  puts "✓ customers.profile_type column exists".green
else
  puts "✗ customers.profile_type column missing".red
  exit(1)
end

if check_column_exists("customers", "profile_id")
  puts "✓ customers.profile_id column exists".green
else
  puts "✗ customers.profile_id column missing".red
  exit(1)
end

# Step 5: Verify removed columns from legal_entities
puts "\n5. Verifying removed columns from legal_entities...".cyan
if !check_column_exists("legal_entities", "oab_id")
  puts "✓ legal_entities.oab_id column removed".green
else
  puts "✗ legal_entities.oab_id column still exists".red
  exit(1)
end

# Step 6: Test model associations
puts "\n6. Testing model associations...".cyan
test_script = <<-RUBY
  # Test LegalEntity associations
  legal_entity = LegalEntity.new(name: "Test Law Firm")
  puts "LegalEntity responds to legal_entity_office: \#{legal_entity.respond_to?(:legal_entity_office)}"
  puts "LegalEntity responds to lawyers: \#{legal_entity.respond_to?(:lawyers)}"
  
  # Test IndividualEntity associations
  individual = IndividualEntity.new(name: "Test", cpf: "12345678901")
  puts "IndividualEntity responds to legal_entity_office_relationships: \#{individual.respond_to?(:legal_entity_office_relationships)}"
  puts "IndividualEntity responds to legal_entity_offices: \#{individual.respond_to?(:legal_entity_offices)}"
  
  # Test Customer associations
  customer = Customer.new(email: "test@example.com")
  puts "Customer responds to profile: \#{customer.respond_to?(:profile)}"
  puts "Customer responds to profile_type: \#{customer.respond_to?(:profile_type)}"
  puts "Customer responds to profile_id: \#{customer.respond_to?(:profile_id)}"
RUBY

File.write("tmp/test_associations.rb", test_script)
run_command("rails runner tmp/test_associations.rb", "Testing model associations")

# Step 7: Test rollback
puts "\n7. Testing rollback capability...".cyan
puts "Do you want to test rollback? (y/n)".yellow
response = gets.chomp.downcase

if response == 'y'
  # Get the version of the first migration
  first_migration_version = "20250810213735" # CreateLegalEntityOffices
  
  puts "\nRolling back to before CreateLegalEntityOffices...".yellow
  run_command("rails db:migrate:down VERSION=20250810214052", "Rolling back RemoveDeprecatedFieldsFromLegalEntity")
  run_command("rails db:migrate:down VERSION=20250810214016", "Rolling back MigrateCustomerDataToPolymorphic")
  run_command("rails db:migrate:down VERSION=20250810213944", "Rolling back MigrateLegalEntityDataToOffice")
  run_command("rails db:migrate:down VERSION=20250810213921", "Rolling back AddPolymorphicAssociationToCustomers")
  run_command("rails db:migrate:down VERSION=20250810213856", "Rolling back CreateLegalEntityOfficeRelationships")
  run_command("rails db:migrate:down VERSION=20250810213735", "Rolling back CreateLegalEntityOffices")
  
  puts "\n✓ Rollback completed successfully".green
  
  puts "\nVerifying rollback...".cyan
  if !check_table_exists("legal_entity_offices")
    puts "✓ legal_entity_offices table removed".green
  else
    puts "✗ legal_entity_offices table still exists".red
  end
  
  if !check_table_exists("legal_entity_office_relationships")
    puts "✓ legal_entity_office_relationships table removed".green
  else
    puts "✗ legal_entity_office_relationships table still exists".red
  end
  
  if check_column_exists("legal_entities", "oab_id")
    puts "✓ legal_entities.oab_id column restored".green
  else
    puts "✗ legal_entities.oab_id column not restored".red
  end
  
  puts "\nDo you want to re-run the migrations? (y/n)".yellow
  rerun = gets.chomp.downcase
  if rerun == 'y'
    run_command("rails db:migrate", "Re-running migrations")
  end
end

puts "\n" + "=" * 80
puts "Migration test completed!".green.bold
puts "=" * 80

# Cleanup
FileUtils.rm_f("tmp/test_associations.rb")