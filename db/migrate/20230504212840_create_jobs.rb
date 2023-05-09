class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :description
      t.date :deadline
      t.string :status
      t.string :priority
      t.string :comment

      t.timestamps
    end
  end
end
