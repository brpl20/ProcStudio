# frozen_string_literal: true

class CreateCustomerPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_phones do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :phone, null: false, foreign_key: true

      t.timestamps
    end
  end
end
