class CreateHonoraries < ActiveRecord::Migration[7.0]
  def change
    create_table :honoraries do |t|
      t.string :fixed_honorary_value
      t.string :parcelling_value
      t.string :honorary_type
      t.string :percent_honorary_value
      t.boolean :parcelling
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
