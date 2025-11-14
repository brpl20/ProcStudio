class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.bigint :team_id, null: false
      t.string :plan_type, null: false, default: 'basic'
      t.string :status, null: false, default: 'active'
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_end
      t.datetime :canceled_at
      t.integer :free_months_remaining, default: 0
      t.integer :extra_users_count, default: 0
      t.jsonb :metadata, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :subscriptions, :team_id, unique: true
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :stripe_customer_id
    add_index :subscriptions, :status
    add_index :subscriptions, :plan_type
    add_index :subscriptions, :deleted_at

    add_foreign_key :subscriptions, :teams
  end
end
