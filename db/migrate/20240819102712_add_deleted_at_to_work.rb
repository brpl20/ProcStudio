class AddDeletedAtToWork < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :deleted_at, :datetime
    add_index :works, :deleted_at
  end
end
