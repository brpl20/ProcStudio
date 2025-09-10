class AddStatusToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :status, :string, default: 'active', null: false
  end
end
