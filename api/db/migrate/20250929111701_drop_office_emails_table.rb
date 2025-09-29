# frozen_string_literal: true

class DropOfficeEmailsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :office_emails, if_exists: true do |t|
      t.bigint :office_id, null: false
      t.bigint :email_id, null: false
      t.datetime :deleted_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :deleted_at
      t.index :email_id
      t.index :office_id
    end
  end
end
