# frozen_string_literal: true

class RemoveUserProfileIdFromJobs < ActiveRecord::Migration[8.0]
  def change
    # Remove the direct relationship column
    remove_column :jobs, :user_profile_id, :bigint
  end
end
