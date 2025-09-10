class RenameLastNameColumnProfileAdmin < ActiveRecord::Migration[7.0]
  def change
    rename_column :profile_admins, :lastname, :last_name
  end
end
