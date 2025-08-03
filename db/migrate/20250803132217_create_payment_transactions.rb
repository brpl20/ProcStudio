class CreatePaymentTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_transactions do |t|
      t.references :subscription, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'BRL'
      t.string :status, default: 'pending'
      t.string :payment_method
      t.string :transaction_id
      t.json :payment_data, default: {}
      t.datetime :processed_at

      t.timestamps
    end

    add_index :payment_transactions, :status
    add_index :payment_transactions, :transaction_id
    add_index :payment_transactions, :processed_at
  end
end
