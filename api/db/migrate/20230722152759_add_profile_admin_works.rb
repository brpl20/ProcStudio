class AddProfileAdminWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_admin_works do |t|
      t.references :profile_admin, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
