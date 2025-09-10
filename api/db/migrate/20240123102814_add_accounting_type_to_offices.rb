class AddAccountingTypeToOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :offices, :accounting_type, :string
    add_index :offices, :accounting_type
  end
end
