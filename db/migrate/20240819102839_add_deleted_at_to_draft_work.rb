class AddDeletedAtToDraftWork < ActiveRecord::Migration[7.0]
  def change
    add_column :draft_works, :deleted_at, :datetime
    add_index :draft_works, :deleted_at
  end
end
