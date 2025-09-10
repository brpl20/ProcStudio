class ChangeCapacityToString < ActiveRecord::Migration[7.0]
  def change
    change_column :profile_customers, :capacity, :string
  end
end
