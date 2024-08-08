class UpdateCreatedBy < ActiveRecord::Migration[7.0]
  def change
    remove_reference :jobs, :created_by, foreign_key: { to_table: :admins }, index: true
    remove_reference :customers, :created_by, foreign_key: { to_table: :admins }, index: true
    remove_reference :works, :created_by, foreign_key: { to_table: :admins }, index: true
    remove_reference :profile_customers, :created_by, foreign_key: { to_table: :admins }, index: true

    add_column :jobs, :created_by_id, :bigint
    add_column :customers, :created_by_id, :bigint
    add_column :works, :created_by_id, :bigint
    add_column :profile_customers, :created_by_id, :bigint

    Job.update_all(created_by_id: Admin.first.id)
    Customer.update_all(created_by_id: Admin.first.id)
    Work.update_all(created_by_id: Admin.first.id)
    ProfileCustomer.update_all(created_by_id: Admin.first.id)
  end
end
