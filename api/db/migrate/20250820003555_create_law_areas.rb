# frozen_string_literal: true

class CreateLawAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :law_areas do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0
      t.references :parent_area, foreign_key: { to_table: :law_areas }, null: true
      t.references :created_by_team, foreign_key: { to_table: :teams }, null: true

      t.timestamps
    end

    # Índices para performance e unicidade
    add_index :law_areas, [:code, :created_by_team_id, :parent_area_id],
              unique: true, name: 'index_law_areas_unique_code'
    add_index :law_areas, :active
  end
end
