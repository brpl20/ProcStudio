# frozen_string_literal: true

class RemoveMessageFromNotifications < ActiveRecord::Migration[8.0]
  def change
    # Remove the redundant message column since we're using body
    remove_column :notifications, :message, :text if column_exists?(:notifications, :message)
    
    # Also remove metadata column if it exists (replaced by data)
    remove_column :notifications, :metadata, :jsonb if column_exists?(:notifications, :metadata)
  end
end