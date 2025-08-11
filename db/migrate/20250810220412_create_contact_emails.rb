class CreateContactEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_emails do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :address
      t.string :email_type
      t.boolean :is_primary
      t.boolean :is_verified

      t.timestamps
    end
  end
end
