class CreateOfficeBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :office_bank_accounts do |t|
      t.references :bank_account, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true

      t.timestamps
    end
  end
end
