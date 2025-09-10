class CreateWorkEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :work_events do |t|
      t.string :status
      t.string :description
      t.datetime :date
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
