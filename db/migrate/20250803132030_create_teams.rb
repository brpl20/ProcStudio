class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.references :main_admin, null: false, 
                   foreign_key: { to_table: :admins }
      t.references :owner_admin, null: false, 
                   foreign_key: { to_table: :admins }
      t.string :status, default: 'active'
      t.json :settings, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :teams, :subdomain, unique: true
    add_index :teams, :deleted_at
    add_index :teams, :status
  end
end
