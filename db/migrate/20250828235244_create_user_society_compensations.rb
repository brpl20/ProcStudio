# frozen_string_literal: true

class CreateUserSocietyCompensations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_society_compensations do |t|
      t.references :user_office, null: false, foreign_key: true
      t.string :compensation_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :effective_date, null: false
      t.date :end_date
      t.string :payment_frequency, null: false, default: 'monthly'
      t.text :notes

      t.timestamps
    end
  end
end
