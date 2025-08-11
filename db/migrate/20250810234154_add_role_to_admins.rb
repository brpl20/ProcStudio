class AddRoleToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :role, :string, default: 'admin'
    add_index :admins, :role
  end
end
