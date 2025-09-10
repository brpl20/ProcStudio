# frozen_string_literal: true

class CreatePowers < ActiveRecord::Migration[7.0]
  def change
    create_table :powers do |t|
      t.string :description, null: false
      t.integer :category, null: false

      t.timestamps
    end
  end
end
