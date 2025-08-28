class MakePhonesPolymorphic < ActiveRecord::Migration[8.0]
  def change
    # Drop join tables that depend on phones
    drop_table :office_phones, if_exists: true
    drop_table :customer_phones, if_exists: true
    
    # Drop and recreate phones table with polymorphic columns
    drop_table :phones, if_exists: true
    
    create_table :phones do |t|
      t.string :phone_number
      t.references :phoneable, polymorphic: true, index: true
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :phones, :deleted_at
  end
end
