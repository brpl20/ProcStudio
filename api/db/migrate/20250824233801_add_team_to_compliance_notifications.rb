# frozen_string_literal: true

class AddTeamToComplianceNotifications < ActiveRecord::Migration[8.0]
  def change
    add_reference :compliance_notifications, :team, null: false, foreign_key: true
  end
end
