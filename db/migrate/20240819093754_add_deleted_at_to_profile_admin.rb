class AddDeletedAtToProfileAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :profile_admins, :deleted_at, :datetime
    add_index :profile_admins, :deleted_at
  end
end
