class CreateTeamOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :team_offices do |t|
      t.references :team, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :team_offices, [:team_id, :office_id], unique: true
    add_index :team_offices, :deleted_at
  end
end
