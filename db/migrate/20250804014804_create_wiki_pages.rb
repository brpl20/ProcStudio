class CreateWikiPages < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content
      t.references :team, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :admins }
      t.references :updated_by, null: false, foreign_key: { to_table: :admins }
      t.references :parent, null: true, foreign_key: { to_table: :wiki_pages }
      t.integer :position, default: 0
      t.boolean :is_published, default: false
      t.boolean :is_locked, default: false
      t.json :metadata, default: {}
      t.datetime :published_at
      t.datetime :deleted_at
      
      t.timestamps
    end

    add_index :wiki_pages, [:team_id, :slug], unique: true
    add_index :wiki_pages, :deleted_at
    add_index :wiki_pages, :is_published
    add_index :wiki_pages, [:team_id, :parent_id]
    add_index :wiki_pages, :position
  end
end
