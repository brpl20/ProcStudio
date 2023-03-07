class CreateOfficeEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :office_emails do |t|
      t.references :office, null: false, foreign_key: true
      t.references :email, null: false, foreign_key: true

      t.timestamps
    end
  end
end
