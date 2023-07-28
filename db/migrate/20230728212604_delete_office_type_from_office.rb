class DeleteOfficeTypeFromOffice < ActiveRecord::Migration[7.0]
  def up
    remove_column :offices, :office_type_id
  end

  def down
    add_column :offices, :office_type_id, :integer
  end
end
