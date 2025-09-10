# frozen_string_literal: true

class CreateCustomerWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_works do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
