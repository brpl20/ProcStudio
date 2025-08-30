# frozen_string_literal: true

class CreateHonoraryComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :honorary_components do |t|
      t.references :honorary, null: false, foreign_key: true
      t.string :component_type, null: false
      t.jsonb :details, null: false, default: {}
      t.boolean :active, default: true
      t.integer :position # for ordering components

      t.timestamps
    end

    add_index :honorary_components, :component_type
    add_index :honorary_components, [:honorary_id, :component_type, :active], name: 'index_honorary_components_lookup'
    add_index :honorary_components, :details, using: :gin
    add_index :honorary_components, :position
  end
end
