class MoveStatusFromWorkEventsToWorks < ActiveRecord::Migration[7.0]
  def up
    remove_column :work_events, :status
    add_column :works, :status, :string, default: 'in_progress'
  end
  
  def down
    add_column :work_events, :status, :string, default: 'in_progress'
    remove_column :works, :status
  end
end
