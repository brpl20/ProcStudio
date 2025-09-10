class RemoveProfileAdminIdFromOffices < ActiveRecord::Migration[7.0]
  def change
    remove_column :offices, :profile_admin_id
  end
end
