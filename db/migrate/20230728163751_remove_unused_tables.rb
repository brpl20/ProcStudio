class RemoveUnusedTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :checklis_documents_works
    drop_table :checklist_documents
    drop_table :checklist_works
    drop_table :checklists
    drop_table :recommendations
    drop_table :office_types
    drop_table :work_updates
  end
end
