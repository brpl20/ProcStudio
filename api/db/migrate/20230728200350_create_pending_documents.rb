class CreatePendingDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :pending_documents do |t|
      t.string :description
      t.references :work, null: false, foreign_key: true
      t.timestamps
    end
  end
end
