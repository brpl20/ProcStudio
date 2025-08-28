class RemoveAddressFieldsFromOffices < ActiveRecord::Migration[8.0]
  def change
    remove_column :offices, :city, :string
    remove_column :offices, :zip_code, :string
    remove_column :offices, :street, :string
    remove_column :offices, :number, :string
    remove_column :offices, :neighborhood, :string
    remove_column :offices, :state, :string
  end
end