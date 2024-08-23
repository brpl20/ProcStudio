class AddDeletedAtToOfficeWork < ActiveRecord::Migration[7.0]
  def change
    add_column :office_works, :deleted_at, :datetime
    add_index :office_works, :deleted_at
  end
end
