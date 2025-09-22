class AddAvatarS3KeyToUserProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :user_profiles, :avatar_s3_key, :string
    add_index :user_profiles, :avatar_s3_key
  end
end
