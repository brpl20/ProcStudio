class AddTempOabToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :temp_oab, :string
  end
end
