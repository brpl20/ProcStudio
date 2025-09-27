# frozen_string_literal: true

class RemoveTypeAccountFromBankAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_column :bank_accounts, :type_account, :string
  end
end
