class RemoveUnusedTables < ActiveRecord::Migration[7.0]
  def change
    def up
      drop_table :checklists_documents
      drop_table :checklists_documents_works
      drop_table :checklist_works
      drop_table :checklists
      drop_table :recommendations
    end
  
    def down
      fail ActiveRecord::IrreversibleMigration
    end
  end
end
