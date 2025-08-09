class CreateWikiCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :team, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :wiki_categories }
      t.integer :position, default: 0
      t.string :color
      t.string :icon
      t.datetime :deleted_at
      
      t.timestamps
    end

    add_index :wiki_categories, [:team_id, :slug], unique: true
    add_index :wiki_categories, :deleted_at
    add_index :wiki_categories, [:team_id, :parent_id]
    add_index :wiki_categories, :position
  end
end
