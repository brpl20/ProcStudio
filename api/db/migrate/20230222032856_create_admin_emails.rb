# frozen_string_literal: true

class CreateAdminEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_emails do |t|
      t.references :email, null: false, foreign_key: true
      t.references :profile_admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
