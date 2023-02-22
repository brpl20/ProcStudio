class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :description
      t.string :zip_code
      t.string :street
      t.integer :number
      t.string :neighborhood
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
