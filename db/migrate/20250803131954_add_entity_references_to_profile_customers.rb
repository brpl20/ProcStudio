class AddEntityReferencesToProfileCustomers < ActiveRecord::Migration[7.0]
  def change
    add_reference :profile_customers, :individual_entity, null: true, foreign_key: true
    add_reference :profile_customers, :legal_entity, null: true, foreign_key: true
  end
end
