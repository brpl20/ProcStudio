# frozen_string_literal: true

class CreateLegalCostTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_cost_types do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :category # e.g., 'judicial', 'administrative', 'notarial', 'tax'
      t.boolean :active, default: true, null: false
      t.boolean :is_system, default: false, null: false
      t.references :team, foreign_key: true, null: true
      t.integer :display_order
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :legal_cost_types, [:key, :team_id], unique: true
    add_index :legal_cost_types, :active
    add_index :legal_cost_types, :is_system
    add_index :legal_cost_types, :category
    add_index :legal_cost_types, :display_order
  end
end
