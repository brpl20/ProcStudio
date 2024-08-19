class AddDeletedAtToOfficeBankAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :office_bank_accounts, :deleted_at, :datetime
    add_index :office_bank_accounts, :deleted_at
  end
end
