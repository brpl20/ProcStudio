class AddCustomerAndProfileAdminToJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobs, :profile_admin
    add_reference :jobs, :customer
  end
end
