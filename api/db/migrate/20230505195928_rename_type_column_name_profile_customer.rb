# frozen_string_literal: true

class RenameTypeColumnNameProfileCustomer < ActiveRecord::Migration[7.0]
  def change
    rename_column :profile_customers, :type, :customer_type
  end
end
