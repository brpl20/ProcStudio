class AddDeletedAtToDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :deleted_at, :datetime
    add_index :documents, :deleted_at
  end
end
