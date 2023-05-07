class RenamePhoneColumnPhones < ActiveRecord::Migration[7.0]
  def change
    rename_column :phones, :phone, :phone_number
  end
end
