class AddDeletedAtToPowerWork < ActiveRecord::Migration[7.0]
  def change
    add_column :power_works, :deleted_at, :datetime
    add_index :power_works, :deleted_at
  end
end
