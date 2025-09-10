class ChangeDefaultStatusOnProfileCustomers < ActiveRecord::Migration[7.0]
  def up
    remove_column :profile_customers, :status
    add_column :profile_customers, :status, :string, null: false, default: 'active'
  end

  def down
    remove_column :profile_customers, :status
    add_column :profile_customers, :status, :integer
  end
end
