class AddDeletedAtToPendingDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :pending_documents, :deleted_at, :datetime
    add_index :pending_documents, :deleted_at
  end
end
