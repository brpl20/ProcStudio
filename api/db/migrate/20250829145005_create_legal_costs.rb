# frozen_string_literal: true

class CreateLegalCosts < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_costs do |t|
      t.references :honorary, null: false, foreign_key: true
      t.boolean :client_responsible, default: true
      t.boolean :include_in_invoices, default: true
      t.decimal :admin_fee_percentage, precision: 5, scale: 2, default: 0

      t.timestamps
    end

    create_table :legal_cost_entries do |t|
      t.references :legal_cost, null: false, foreign_key: true
      t.string :cost_type, null: false # maps to BRAZILIAN_COST_TYPES
      t.string :name, null: false
      t.text :description
      t.decimal :amount, precision: 10, scale: 2
      t.boolean :estimated, default: false
      t.boolean :paid, default: false
      t.date :due_date
      t.date :payment_date
      t.string :receipt_number
      t.string :payment_method
      t.jsonb :metadata, default: {} # for additional fields

      t.timestamps
    end

    add_index :legal_cost_entries, :cost_type
    add_index :legal_cost_entries, [:legal_cost_id, :paid]
    add_index :legal_cost_entries, :due_date
    add_index :legal_cost_entries, :payment_date
  end
end
