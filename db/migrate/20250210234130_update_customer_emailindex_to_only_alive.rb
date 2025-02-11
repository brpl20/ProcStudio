class UpdateCustomerEmailindexToOnlyAlive < ActiveRecord::Migration[7.0]
  def change
    remove_index :customers, :email
    add_index :customers, :email, unique: true, where: "deleted_at IS NULL", name: "index_customers_on_email_where_not_deleted"
  end
end
