class CreateAdminBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_bank_accounts do |t|
      t.references :bank_account, null: false, foreign_key: true
      t.references :profile_admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
