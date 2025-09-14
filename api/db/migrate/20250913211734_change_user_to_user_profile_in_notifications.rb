# frozen_string_literal: true

class ChangeUserToUserProfileInNotifications < ActiveRecord::Migration[8.0]
  def change
    # Add user_profile_id column if it doesn't exist
    unless column_exists?(:notifications, :user_profile_id)
      add_reference :notifications, :user_profile, foreign_key: true, index: true
    end

    # Migrate data from user_id to user_profile_id
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE notifications n
          SET user_profile_id = up.id
          FROM user_profiles up
          WHERE n.user_id = up.user_id
            AND n.user_profile_id IS NULL
        SQL
      end
    end

    # Remove old user_id column and its indexes in a separate migration
    # to avoid issues with existing data
    # We'll keep user_id for now for backward compatibility
  end
end