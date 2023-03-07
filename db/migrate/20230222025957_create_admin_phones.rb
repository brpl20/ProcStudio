# frozen_string_literal: true

class CreateAdminPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_phones do |t|
      t.references :phone, null: false, foreign_key: true
      t.references :profile_admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
