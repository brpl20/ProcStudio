# frozen_string_literal: true

class UpdateJobsProfileAdminToUserProfile < ActiveRecord::Migration[8.0]
  def change
    # Rename profile_admin_id to user_profile_id in jobs table
    rename_column :jobs, :profile_admin_id, :user_profile_id

    # Update the index if it exists
    return unless index_exists?(:jobs, :profile_admin_id)

    remove_index :jobs, :profile_admin_id
    add_index :jobs, :user_profile_id
  end
end
