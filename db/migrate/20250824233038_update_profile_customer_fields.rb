# frozen_string_literal: true

class UpdateProfileCustomerFields < ActiveRecord::Migration[8.0]
  def change
    # Remove unused invalid_person field
    remove_column :profile_customers, :invalid_person, :integer

    # Add deceased_at to track when a customer died
    add_column :profile_customers, :deceased_at, :datetime
    add_index :profile_customers, :deceased_at
  end
end
