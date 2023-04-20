# frozen_string_literal: true

class AddJwtTokenToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :jwt_token, :string
    add_index :admins, :jwt_token, unique: true
  end
end
