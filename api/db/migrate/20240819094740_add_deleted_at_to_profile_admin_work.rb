class AddDeletedAtToProfileAdminWork < ActiveRecord::Migration[7.0]
  def change
    add_column :profile_admin_works, :deleted_at, :datetime
    add_index :profile_admin_works, :deleted_at
  end
end
