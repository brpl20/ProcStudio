class AddLawyersToWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :lawyers, :json
  end
end
