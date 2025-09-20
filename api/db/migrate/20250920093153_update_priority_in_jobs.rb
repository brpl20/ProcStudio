# frozen_string_literal: true

class UpdatePriorityInJobs < ActiveRecord::Migration[8.0]
  def up
    # Update existing priority values to match the new enum values
    execute <<-SQL.squish
      UPDATE jobs#{' '}
      SET priority = CASE#{' '}
        WHEN priority IS NULL OR priority = '' THEN 'medium'
        WHEN LOWER(priority) IN ('low', 'medium', 'high', 'urgent') THEN LOWER(priority)
        ELSE 'medium'
      END
    SQL
  end

  def down
    # If needed, you can revert to original values here
  end
end
