class CreateWikiPageRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_page_revisions do |t|
      t.references :wiki_page, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.integer :version_number, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :admins }
      t.text :change_summary
      t.json :diff_data, default: {}
      t.datetime :deleted_at
      
      t.timestamps
    end

    add_index :wiki_page_revisions, [:wiki_page_id, :version_number], unique: true
    add_index :wiki_page_revisions, :deleted_at
  end
end
