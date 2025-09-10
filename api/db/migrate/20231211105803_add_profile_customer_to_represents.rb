class AddProfileCustomerToRepresents < ActiveRecord::Migration[7.0]
  def change
    add_reference :represents, :profile_admin, null: false, foreign_key: true, index: true
    remove_column :represents, :represented_id, :integer
  end
end
