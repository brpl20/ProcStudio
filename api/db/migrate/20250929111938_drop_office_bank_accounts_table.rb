class DropOfficeBankAccountsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :office_bank_accounts, if_exists: true do |t|
      t.bigint :bank_account_id, null: false
      t.bigint :office_id, null: false
      t.datetime :deleted_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :bank_account_id
      t.index :deleted_at
      t.index :office_id
    end
  end
end
