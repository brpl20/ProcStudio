class AddProfileAdminsFieldsToWork < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :physical_lawyer, :integer
    add_column :works, :responsible_lawyer, :integer
    add_column :works, :partner_lawyer, :integer
    add_column :works, :intern, :integer
    add_column :works, :bachelor, :integer
  end
end
