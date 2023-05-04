class CreateJobWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :job_works do |t|
      t.references :job, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true
      t.references :profile_admin, null: false, foreign_key: true
      t.references :profile_customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
