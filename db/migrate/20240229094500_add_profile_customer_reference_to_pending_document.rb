class AddProfileCustomerReferenceToPendingDocument < ActiveRecord::Migration[7.0]
  def change
    add_reference :pending_documents, :profile_customer, null: true, foreign_key: true
  end
end
