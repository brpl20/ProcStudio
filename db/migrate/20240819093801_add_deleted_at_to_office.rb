class AddDeletedAtToOffice < ActiveRecord::Migration[7.0]
  def change
    add_column :offices, :deleted_at, :datetime
    add_index :offices, :deleted_at
  end
end
