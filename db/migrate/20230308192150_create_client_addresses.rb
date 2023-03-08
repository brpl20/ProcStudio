class CreateClientAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :client_addresses do |t|
      t.references :profile_customer, null: false, foreign_key: true
      t.references :addresses, null: false, foreign_key: true

      t.timestamps
    end
  end
end
