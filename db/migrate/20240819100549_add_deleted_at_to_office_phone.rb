class AddDeletedAtToOfficePhone < ActiveRecord::Migration[7.0]
  def change
    add_column :office_phones, :deleted_at, :datetime
    add_index :office_phones, :deleted_at
  end
end
