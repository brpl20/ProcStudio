class CreateChecklistDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_documents do |t|
      t.string :description

      t.timestamps
    end
  end
end
