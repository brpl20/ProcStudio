class CreateWikiPageCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_page_categories do |t|
      t.references :wiki_page, null: false, foreign_key: true
      t.references :wiki_category, null: false, foreign_key: true
      
      t.timestamps
    end

    add_index :wiki_page_categories, [:wiki_page_id, :wiki_category_id], unique: true, name: 'index_wiki_page_categories_unique'
  end
end
