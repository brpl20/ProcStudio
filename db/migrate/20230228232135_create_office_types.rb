# frozen_string_literal: true

class CreateOfficeTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :office_types do |t|
      t.string :description

      t.timestamps
    end
  end
end
