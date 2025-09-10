class AddDeletedAtToAdminEmail < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_emails, :deleted_at, :datetime
    add_index :admin_emails, :deleted_at
  end
end
