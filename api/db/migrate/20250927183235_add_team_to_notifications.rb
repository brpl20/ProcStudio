# frozen_string_literal: true

class AddTeamToNotifications < ActiveRecord::Migration[8.0]
  def change
    # rubocop:disable Rails/NotNullColumn
    add_reference :notifications, :team, null: false, foreign_key: true
    # rubocop:enable Rails/NotNullColumn
  end
end
