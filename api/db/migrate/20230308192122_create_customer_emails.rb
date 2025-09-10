# frozen_string_literal: true

class CreateCustomerEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_emails do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :email, null: false, foreign_key: true

      t.timestamps
    end
  end
end
