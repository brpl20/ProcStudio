class RemoveCustomerAndAddProfileCustomerToJobs < ActiveRecord::Migration[7.0]
  def change
    remove_column :jobs, :customer_id
    add_reference :jobs, :profile_customer
  end
end
