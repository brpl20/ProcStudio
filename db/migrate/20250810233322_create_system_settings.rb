class CreateSystemSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :system_settings do |t|
      t.string :key, null: false
      t.decimal :value, precision: 10, scale: 2
      t.integer :year, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :system_settings, [:key, :year], unique: true
    add_index :system_settings, :active
  end
end
