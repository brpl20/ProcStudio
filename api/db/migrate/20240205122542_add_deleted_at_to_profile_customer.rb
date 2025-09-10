class AddDeletedAtToProfileCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :profile_customers, :deleted_at, :datetime
    add_index :profile_customers, :deleted_at
  end
end
