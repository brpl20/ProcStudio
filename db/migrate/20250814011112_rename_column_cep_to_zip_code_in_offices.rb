class RenameColumnCepToZipCodeInOffices < ActiveRecord::Migration[7.0]
  def change
    rename_column :offices, :cep, :zip_code
  end
end
