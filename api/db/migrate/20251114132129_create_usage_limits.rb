class CreateUsageLimits < ActiveRecord::Migration[8.0]
  def change
    create_table :usage_limits do |t|
      t.bigint :team_id, null: false
      t.integer :customers_count, default: 0
      t.integer :jobs_count, default: 0
      t.integer :works_count, default: 0
      t.integer :documents_generated_total, default: 0
      t.integer :documents_generated_month, default: 0
      t.datetime :period_start
      t.datetime :period_end

      t.timestamps
    end

    add_index :usage_limits, :team_id, unique: true
    add_foreign_key :usage_limits, :teams
  end
end
