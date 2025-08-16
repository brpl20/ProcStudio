class AddOabToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :oab, :string
  end
end
