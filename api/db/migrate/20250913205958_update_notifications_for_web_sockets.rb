# frozen_string_literal: true

class UpdateNotificationsForWebSockets < ActiveRecord::Migration[8.0]
  def change
    # Add missing columns to notifications table
    add_column :notifications, :body, :text unless column_exists?(:notifications, :body)
    add_column :notifications, :notification_type, :string unless column_exists?(:notifications, :notification_type)
    add_column :notifications, :data, :jsonb, default: {} unless column_exists?(:notifications, :data)
    add_column :notifications, :action_url, :string unless column_exists?(:notifications, :action_url)
    add_column :notifications, :sender_type, :string unless column_exists?(:notifications, :sender_type)
    add_column :notifications, :sender_id, :bigint unless column_exists?(:notifications, :sender_id)

    # Rename message to body if it exists
    if column_exists?(:notifications, :message) && !column_exists?(:notifications, :body)
      rename_column :notifications, :message, :body
    end

    # Rename metadata to data if it exists
    if column_exists?(:notifications, :metadata) && !column_exists?(:notifications, :data)
      rename_column :notifications, :metadata, :data
    end

    # Add default values to existing columns
    change_column_default :notifications, :read, false if column_exists?(:notifications, :read)
    change_column_default :notifications, :priority, 0 if column_exists?(:notifications, :priority)

    # Add indexes for performance
    add_index :notifications, :read unless index_exists?(:notifications, :read)
    add_index :notifications, :notification_type unless index_exists?(:notifications, :notification_type)
    add_index :notifications, :priority unless index_exists?(:notifications, :priority)
    add_index :notifications, [:sender_type, :sender_id] unless index_exists?(:notifications, [:sender_type, :sender_id])
    add_index :notifications, [:user_id, :read] unless index_exists?(:notifications, [:user_id, :read])
    add_index :notifications, :created_at unless index_exists?(:notifications, :created_at)
  end
end