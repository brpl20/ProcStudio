class CreateOfficeWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :office_works do |t|
      t.references :work, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true
      t.timestamps
    end
  end
end
