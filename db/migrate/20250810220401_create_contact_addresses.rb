class CreateContactAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_addresses do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :street
      t.string :number
      t.string :complement
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.boolean :is_primary

      t.timestamps
    end
  end
end
