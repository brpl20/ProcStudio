class RemoveStatusFromUserProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :user_profiles, :status, :string
  end
end