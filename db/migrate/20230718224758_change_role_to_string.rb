class ChangeRoleToString < ActiveRecord::Migration[7.0]
  def change
    change_column :profile_admins, :role, :string
    change_column :profile_admins, :status, :string
    change_column :offices, :society, :string
  end
end
