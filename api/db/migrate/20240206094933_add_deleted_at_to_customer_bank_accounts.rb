class AddDeletedAtToCustomerBankAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_bank_accounts, :deleted_at, :datetime
    add_index :customer_bank_accounts, :deleted_at
  end
end
