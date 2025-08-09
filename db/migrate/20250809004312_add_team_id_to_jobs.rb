class AddTeamIdToJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobs, :team, null: true, foreign_key: true
  end
end
