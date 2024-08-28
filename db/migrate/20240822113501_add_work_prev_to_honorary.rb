class AddWorkPrevToHonorary < ActiveRecord::Migration[7.0]
  def change
    add_column :honoraries, :work_prev, :integer
  end
end
