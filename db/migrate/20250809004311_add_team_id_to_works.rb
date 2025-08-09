class AddTeamIdToWorks < ActiveRecord::Migration[7.0]
  def change
    add_reference :works, :team, null: true, foreign_key: true
  end
end
