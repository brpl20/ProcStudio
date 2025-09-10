class RenameExtraPendingDocuments < ActiveRecord::Migration[7.0]
  def change
    rename_column :works, :pending_document, :extra_pending_document
  end
end
