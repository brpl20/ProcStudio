# frozen_string_literal: true

class CreateJobUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :job_user_profiles do |t|
      t.references :job, null: false, foreign_key: true
      t.references :user_profile, null: false, foreign_key: true
      t.string :role, default: 'assignee' # assignee, supervisor, reviewer, etc.
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :job_user_profiles, [:job_id, :user_profile_id], unique: true
    add_index :job_user_profiles, :deleted_at
  end
end
