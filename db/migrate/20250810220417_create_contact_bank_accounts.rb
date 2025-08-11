class CreateContactBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_bank_accounts do |t|
      t.references :contactable, polymorphic: true, null: false
      t.string :bank_name
      t.string :bank_code
      t.string :agency
      t.string :account_number
      t.string :account_type
      t.string :pix_key
      t.boolean :is_primary

      t.timestamps
    end
  end
end
