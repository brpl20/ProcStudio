class AddPolymorphicAssociationToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :profile_type, :string
    add_column :customers, :profile_id, :integer
    add_index :customers, [:profile_type, :profile_id], name: 'index_customers_on_profile'
  end
end
