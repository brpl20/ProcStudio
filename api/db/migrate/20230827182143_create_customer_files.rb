class CreateCustomerFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_files do |t|
      t.string :file_description
      t.references :profile_customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
