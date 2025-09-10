class CreateTributaries < ActiveRecord::Migration[7.0]
  def change
    create_table :tributaries do |t|
      t.integer :compensation
      t.integer :craft
      t.integer :lawsuit
      t.date :pojection
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
