class AddColumnResponsibleLawyerToOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :offices, :responsible_lawyer_id, :integer
    add_index :offices, :responsible_lawyer_id
  end
end
