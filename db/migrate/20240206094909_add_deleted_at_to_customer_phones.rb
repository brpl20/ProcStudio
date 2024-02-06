class AddDeletedAtToCustomerPhones < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_phones, :deleted_at, :datetime
    add_index :customer_phones, :deleted_at
  end
end
