class RemoveTempOabAndStatusFromAdmins < ActiveRecord::Migration[7.0]
  def change
    remove_column :admins, :temp_oab, :string
    remove_column :admins, :status, :string
  end
end
