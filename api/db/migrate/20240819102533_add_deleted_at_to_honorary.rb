class AddDeletedAtToHonorary < ActiveRecord::Migration[7.0]
  def change
    add_column :honoraries, :deleted_at, :datetime
    add_index :honoraries, :deleted_at
  end
end
