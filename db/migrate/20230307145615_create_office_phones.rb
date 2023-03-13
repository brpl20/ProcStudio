# frozen_string_literal: true

class CreateOfficePhones < ActiveRecord::Migration[7.0]
  def change
    create_table :office_phones do |t|
      t.references :office, null: false, foreign_key: true
      t.references :phone, null: false, foreign_key: true

      t.timestamps
    end
  end
end
