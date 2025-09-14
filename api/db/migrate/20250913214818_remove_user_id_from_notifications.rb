# frozen_string_literal: true

class RemoveUserIdFromNotifications < ActiveRecord::Migration[8.0]
  def change
    # Remove the old user_id column and its indexes
    remove_index :notifications, :user_id if index_exists?(:notifications, :user_id)
    remove_index :notifications, [:user_id, :read] if index_exists?(:notifications, [:user_id, :read])
    remove_column :notifications, :user_id, :integer if column_exists?(:notifications, :user_id)
    
    # Also remove team_id if it exists (notifications belong to user_profile, which has team through user)
    remove_index :notifications, :team_id if index_exists?(:notifications, :team_id)
    remove_column :notifications, :team_id, :integer if column_exists?(:notifications, :team_id)
  end
end