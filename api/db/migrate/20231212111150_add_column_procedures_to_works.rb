class AddColumnProceduresToWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :procedures, :text, array: true, default: []
  end
end
