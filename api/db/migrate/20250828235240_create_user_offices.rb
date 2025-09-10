# frozen_string_literal: true

class CreateUserOffices < ActiveRecord::Migration[8.0]
  def change
    create_table :user_offices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true
      t.string :partnership_type, null: false
      t.decimal :partnership_percentage, precision: 5, scale: 2, default: 0.0
      t.boolean :is_administrator, default: false, null: false
      t.string :cna_link
      t.date :entry_date

      t.timestamps
    end

    add_index :user_offices, [:user_id, :office_id], unique: true
  end
end
