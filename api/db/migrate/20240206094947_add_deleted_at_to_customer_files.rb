class AddDeletedAtToCustomerFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_files, :deleted_at, :datetime
    add_index :customer_files, :deleted_at
  end
end
