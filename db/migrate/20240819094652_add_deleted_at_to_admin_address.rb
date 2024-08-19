class AddDeletedAtToAdminAddress < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_addresses, :deleted_at, :datetime
    add_index :admin_addresses, :deleted_at
  end
end
