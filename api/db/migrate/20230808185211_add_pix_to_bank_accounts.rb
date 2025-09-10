class AddPixToBankAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :pix, :string
  end
end
