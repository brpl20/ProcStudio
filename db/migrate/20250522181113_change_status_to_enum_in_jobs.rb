class ChangeStatusToEnumInJobs < ActiveRecord::Migration[7.0]
  def up
    Job.where(status: 'late').update_all(status: 'delayed')
    allowed_values = %w[pending delayed finished]
    Job.where.not(status: allowed_values).update_all(status: 'pending')
  end

  def down
    Job.where(status: 'delayed').update_all(status: 'string_late')
  end
end
