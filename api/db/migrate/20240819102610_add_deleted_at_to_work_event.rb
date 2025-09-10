class AddDeletedAtToWorkEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :work_events, :deleted_at, :datetime
    add_index :work_events, :deleted_at
  end
end
