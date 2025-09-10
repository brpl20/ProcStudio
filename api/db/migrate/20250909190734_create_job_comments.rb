# frozen_string_literal: true

class CreateJobComments < ActiveRecord::Migration[8.0]
  def change
    create_table :job_comments do |t|
      t.text :content, null: false
      t.references :user_profile, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :job_comments, :deleted_at
    add_index :job_comments, [:job_id, :created_at]
  end
end
