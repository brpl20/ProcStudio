class CreateBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_accounts do |t|
      t.string :bank_name
      t.string :type_account
      t.string :agency
      t.string :account
      t.string :operation

      t.timestamps
    end
  end
end
