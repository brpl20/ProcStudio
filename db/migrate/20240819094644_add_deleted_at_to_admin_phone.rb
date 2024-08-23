class AddDeletedAtToAdminPhone < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_phones, :deleted_at, :datetime
    add_index :admin_phones, :deleted_at
  end
end
