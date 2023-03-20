# frozen_string_literal: true

class CreateCustomerBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_bank_accounts do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :bank_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
