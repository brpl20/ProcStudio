class AddProfileCustomerReferenceToDocument < ActiveRecord::Migration[7.0]
  def change
    add_reference :documents, :profile_customer, null: true, foreign_key: true
  end
end
