class ChangePriorityToIntegerInNotifications < ActiveRecord::Migration[7.0]
  def up
    # Remove the default value first
    change_column_default :notifications, :priority, nil
    
    # Update existing string values to ensure they're valid integers
    execute <<-SQL
      UPDATE notifications 
      SET priority = CASE priority
        WHEN '0' THEN '0'
        WHEN '1' THEN '1'
        WHEN '2' THEN '2'
        WHEN '3' THEN '3'
        ELSE '1'
      END
      WHERE priority IS NOT NULL
    SQL

    # Change column type to integer
    execute <<-SQL
      ALTER TABLE notifications 
      ALTER COLUMN priority TYPE integer 
      USING priority::integer
    SQL
    
    # Set the new default value
    change_column_default :notifications, :priority, 1
    
    # Add index for better query performance
    add_index :notifications, [:user_profile_id, :priority, :created_at], 
              name: 'index_notifications_on_user_profile_priority_created'
  end

  def down
    remove_index :notifications, name: 'index_notifications_on_user_profile_priority_created'
    
    # Remove default
    change_column_default :notifications, :priority, nil
    
    # Change back to string
    execute <<-SQL
      ALTER TABLE notifications 
      ALTER COLUMN priority TYPE varchar 
      USING priority::varchar
    SQL
    
    # Set default back
    change_column_default :notifications, :priority, '1'
  end
end