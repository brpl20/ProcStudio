class AddDeletedAtToCustomerWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_works, :deleted_at, :datetime
    add_index :customer_works, :deleted_at
  end
end
