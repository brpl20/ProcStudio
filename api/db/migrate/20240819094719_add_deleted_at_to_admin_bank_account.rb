class AddDeletedAtToAdminBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_bank_accounts, :deleted_at, :datetime
    add_index :admin_bank_accounts, :deleted_at
  end
end
