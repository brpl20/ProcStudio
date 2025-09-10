# frozen_string_literal: true

class CreateProfileAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_admins do |t|
      t.integer :role
      t.string :name
      t.string :lastname
      t.integer :gender
      t.string :oab
      t.string :rg
      t.string :cpf
      t.string :nationality
      t.integer :civil_status
      t.date :birth
      t.string :mother_name
      t.integer :status
      t.references :admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
