class RemoveOfficeIdFromWork < ActiveRecord::Migration[7.0]
  def up
    remove_column :works, :office_id
  end

  def down
    add_column :works, :office_id, :integer
  end
end
