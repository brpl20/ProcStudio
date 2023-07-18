class ChangeCivilStatusToString < ActiveRecord::Migration[7.0]
  def change
    change_column :profile_customers, :civil_status, :string
    change_column :profile_admins, :civil_status, :string
  end
end
