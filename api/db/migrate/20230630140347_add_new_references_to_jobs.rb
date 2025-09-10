class AddNewReferencesToJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobs, :profile_admin
    add_reference :jobs, :customer
    add_reference :jobs, :work
  end
end
