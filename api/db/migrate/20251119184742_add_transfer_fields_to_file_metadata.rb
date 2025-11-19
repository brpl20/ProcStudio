class AddTransferFieldsToFileMetadata < ActiveRecord::Migration[8.0]
  def change
    add_column :file_metadata, :transferred_at, :datetime
    add_column :file_metadata, :transferred_by_id, :integer
    add_column :file_metadata, :transfer_metadata, :jsonb

    # Add indexes for better query performance
    add_index :file_metadata, :transferred_at
    add_index :file_metadata, :transferred_by_id
    add_index :file_metadata, :transfer_metadata, using: :gin
  end
end
