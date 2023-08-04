class RemovePerdlaunch < ActiveRecord::Migration[7.0]
  def change
    drop_table :perdlaunches do |t|
      t.integer :compensation
      t.integer :craft
      t.integer :lawsuit
      t.date :projection
      t.string :perd_number
      t.date :shipping_date
      t.date :payment_date
      t.integer :status
      t.string :value
      t.string :responsible
      t.string :perd_style
      t.references :work, null: false, foreign_key: true
      t.timestamps
    end
  end
end
