class AddJwtTokenToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :jwt_token, :string
  end
end
