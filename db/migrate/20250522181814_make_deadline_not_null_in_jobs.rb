class MakeDeadlineNotNullInJobs < ActiveRecord::Migration[7.0]
  def up
    Job.where(deadline: nil).update_all(deadline: Date.today)

    change_column_null :jobs, :deadline, false
  end

  def down
    change_column_null :jobs, :deadline, true
  end
end
