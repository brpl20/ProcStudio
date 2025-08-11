class CreateContactPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_phones do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :number
      t.string :phone_type
      t.boolean :is_primary
      t.boolean :is_whatsapp

      t.timestamps
    end
  end
end
