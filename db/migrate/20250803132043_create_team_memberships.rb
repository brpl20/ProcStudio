class CreateTeamMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :team_memberships do |t|
      t.references :team, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.string :role, null: false, default: 'lawyer'
      t.string :status, default: 'active'
      t.datetime :joined_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :team_memberships, [:team_id, :admin_id], unique: true
    add_index :team_memberships, :role
    add_index :team_memberships, :status
    add_index :team_memberships, :deleted_at
  end
end
