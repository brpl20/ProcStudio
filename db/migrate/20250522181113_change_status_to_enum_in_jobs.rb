class ChangeStatusToEnumInJobs < ActiveRecord::Migration[7.0]
  def up
    Job.where(status: 'late').update_all(status: 'delayed')
    allowed_values = %w[pending delayed finished]
    Job.where.not(status: allowed_values).update_all(status: 'pending')

    execute <<-SQL
      ALTER TABLE jobs
      ADD CONSTRAINT status_enum_check
      CHECK (status IN ('pending', 'delayed', 'finished'));
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE jobs
      DROP CONSTRAINT IF EXISTS status_enum_check;
    SQL

    Job.where(status: 'delayed').update_all(status: 'string_late')
  end
end
