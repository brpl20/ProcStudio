class AddColumnAccountantIdToProfileCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :profile_customers, :accountant_id, :integer
    add_index :profile_customers, :accountant_id
  end
end
