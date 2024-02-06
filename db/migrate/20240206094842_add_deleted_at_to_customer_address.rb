class AddDeletedAtToCustomerAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_addresses, :deleted_at, :datetime
    add_index :customer_addresses, :deleted_at
  end
end
