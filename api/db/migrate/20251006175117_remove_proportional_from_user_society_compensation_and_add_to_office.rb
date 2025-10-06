# frozen_string_literal: true

class RemoveProportionalFromUserSocietyCompensationAndAddToOffice < ActiveRecord::Migration[8.0]
  def up
    # Add proportional field to offices table
    add_column :offices, :proportional, :boolean, default: false, null: false
    
    # Note: quote_value and number_of_quotes already exist in the offices table
    # as shown in the Office model schema
    
    # Remove 'proportional' from the compensation_type enum values
    # First, we need to update any existing records with 'proportional' type
    UserSocietyCompensation.where(compensation_type: 'proportional').update_all(compensation_type: 'pro_labore')
    
    # Now we can safely remove the constraint and recreate it without 'proportional'
    execute <<-SQL
      ALTER TABLE user_society_compensations 
      DROP CONSTRAINT IF EXISTS user_society_compensations_compensation_type_check;
    SQL
    
    execute <<-SQL
      ALTER TABLE user_society_compensations
      ADD CONSTRAINT user_society_compensations_compensation_type_check
      CHECK (compensation_type IN ('pro_labore', 'salary'));
    SQL
  end
  
  def down
    # Remove proportional field from offices table
    remove_column :offices, :proportional
    
    # Restore 'proportional' to the compensation_type enum
    execute <<-SQL
      ALTER TABLE user_society_compensations 
      DROP CONSTRAINT IF EXISTS user_society_compensations_compensation_type_check;
    SQL
    
    execute <<-SQL
      ALTER TABLE user_society_compensations
      ADD CONSTRAINT user_society_compensations_compensation_type_check
      CHECK (compensation_type IN ('pro_labore', 'salary', 'proportional'));
    SQL
  end
end
