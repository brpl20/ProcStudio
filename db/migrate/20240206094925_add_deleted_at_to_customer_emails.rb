class AddDeletedAtToCustomerEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :customer_emails, :deleted_at, :datetime
    add_index :customer_emails, :deleted_at
  end
end
