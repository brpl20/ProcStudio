class RemoveUnusedWorkFields < ActiveRecord::Migration[7.0]
  def up
    remove_column :works, :action
    remove_column :works, :rate_percentage
    remove_column :works, :rate_percentage_exfield
    remove_column :works, :rate_fixed
    remove_column :works, :checklist
  end

  def down
    add_column :works, :office_id, :integer

    add_column :works, :action, :string
    add_column :works, :rate_percentage, :string
    add_column :works, :rate_percentage_exfield, :string
    add_column :works, :rate_fixed, :string
    add_column :works, :checklist, :string
  end
end
