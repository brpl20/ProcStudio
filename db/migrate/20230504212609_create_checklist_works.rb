class CreateChecklistWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_works do |t|
      t.references :checklist, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
