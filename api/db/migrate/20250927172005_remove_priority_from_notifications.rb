# frozen_string_literal: true

class RemovePriorityFromNotifications < ActiveRecord::Migration[8.0]
  def change
    remove_index :notifications, :priority
    remove_index :notifications, name: :index_notifications_on_user_profile_priority_created
    remove_column :notifications, :priority, :integer
  end
end
