class CreateWorkConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :work_configurations do |t|
      t.references :work, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.jsonb :configuration, null: false, default: {}
      t.integer :version, default: 1, null: false
      t.string :status, default: 'active'
      t.text :notes
      t.references :created_by, foreign_key: { to_table: :admins }
      t.references :updated_by, foreign_key: { to_table: :admins }
      t.datetime :effective_from, null: false
      t.datetime :effective_until
      t.timestamps
    end
    
    add_index :work_configurations, :configuration, using: :gin
    add_index :work_configurations, [:work_id, :version], unique: true
    add_index :work_configurations, [:work_id, :status]
    add_index :work_configurations, [:work_id, :effective_from]
  end
end
