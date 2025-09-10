# frozen_string_literal: true

class RenameLastnameColumnProfileCustomers < ActiveRecord::Migration[7.0]
  def change
    rename_column :profile_customers, :lastname, :last_name
  end
end
