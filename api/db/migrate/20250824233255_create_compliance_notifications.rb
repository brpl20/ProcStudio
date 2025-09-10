# frozen_string_literal: true

class CreateComplianceNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_notifications do |t|
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, default: 'pending', null: false
      t.string :resource_type
      t.bigint :resource_id
      t.json :metadata
      t.datetime :resolved_at
      t.datetime :ignored_at
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :compliance_notifications, [:resource_type, :resource_id]
    add_index :compliance_notifications, :status
    add_index :compliance_notifications, :notification_type
  end
end
