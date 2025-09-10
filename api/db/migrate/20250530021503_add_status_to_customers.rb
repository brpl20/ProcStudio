class AddStatusToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :status, :string, default: 'active', null: false
  end
end
