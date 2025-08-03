class CreateSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :currency, default: 'BRL'
      t.string :billing_interval # 'monthly', 'yearly'
      t.integer :max_users
      t.integer :max_offices
      t.integer :max_cases
      t.json :features, default: {}
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :subscription_plans, :is_active
    add_index :subscription_plans, :billing_interval
  end
end
