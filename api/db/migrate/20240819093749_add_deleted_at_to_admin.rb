class AddDeletedAtToAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :deleted_at, :datetime
    add_index :admins, :deleted_at
  end
end
