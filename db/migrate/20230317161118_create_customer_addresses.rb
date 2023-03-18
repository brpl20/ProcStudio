# frozen_string_literal: true

class CreateCustomerAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_addresses do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
