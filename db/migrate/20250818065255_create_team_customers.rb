class CreateTeamCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_customers do |t|
      t.references :team, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :customer_email, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :team_customers, [:team_id, :customer_email], unique: true
    add_index :team_customers, [:team_id, :customer_id], unique: true
    add_index :team_customers, :deleted_at
  end
end
