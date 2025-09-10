class CreateChecklisDocumentsWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :checklis_documents_works do |t|
      t.references :checklist_document, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
