class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :team, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.string :status, default: 'trial'
      t.date :trial_end_date
      t.decimal :monthly_amount, precision: 10, scale: 2
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :subscriptions, [:team_id, :status]
    add_index :subscriptions, :deleted_at
    add_index :subscriptions, :status
  end
end
