class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.jsonb :settings, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :teams, :subdomain, unique: true
    add_index :teams, :deleted_at
  end
end
