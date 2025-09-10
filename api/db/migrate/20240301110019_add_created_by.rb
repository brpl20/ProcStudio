class AddCreatedBy < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobs, :created_by, foreign_key: { to_table: :admins }, index: true
    add_reference :customers, :created_by, foreign_key: { to_table: :admins }, index: true
    add_reference :works, :created_by, foreign_key: { to_table: :admins }, index: true
    add_reference :profile_customers, :created_by, foreign_key: { to_table: :admins }, index: true
  end
end
