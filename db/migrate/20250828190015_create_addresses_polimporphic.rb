class CreateAddressesPolimporphic < ActiveRecord::Migration[8.0]
  def up
    # First, drop the join tables that depend on addresses
    drop_table :customer_addresses if table_exists?(:customer_addresses)
    drop_table :user_addresses if table_exists?(:user_addresses)
    drop_table :admin_addresses if table_exists?(:admin_addresses)
    
    # Now we can safely drop the addresses table
    drop_table :addresses if table_exists?(:addresses)
    
    # Create new polymorphic table
    create_table :addresses do |t|
      t.string :zip_code, null: false
      t.string :street, null: false
      t.string :number
      t.string :complement
      t.string :neighborhood
      t.string :city, null: false
      t.string :state, null: false
      t.references :addressable, polymorphic: true, null: false, index: true
      t.string :address_type, default: 'main'
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :addresses, :deleted_at
    add_index :addresses, :zip_code
    add_index :addresses, [:city, :state]
  end
  
  def down
    drop_table :addresses
  end
end
