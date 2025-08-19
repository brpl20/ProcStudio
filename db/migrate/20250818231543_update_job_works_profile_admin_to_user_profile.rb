# frozen_string_literal: true

class UpdateJobWorksProfileAdminToUserProfile < ActiveRecord::Migration[8.0]
  def change
    # Rename profile_admin_id to user_profile_id in job_works table
    rename_column :job_works, :profile_admin_id, :user_profile_id

    # Update the index if it exists
    return unless index_exists?(:job_works, :profile_admin_id)

    remove_index :job_works, :profile_admin_id
    add_index :job_works, :user_profile_id
  end
end
