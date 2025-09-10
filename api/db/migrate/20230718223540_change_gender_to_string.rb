class ChangeGenderToString < ActiveRecord::Migration[7.0]
  def change
    change_column :profile_customers, :gender, :string
    change_column :profile_admins, :gender, :string
  end
end
