class CreateTempUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :temp_uploads do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :original_filename, null: false
      t.string :content_type
      t.bigint :byte_size
      t.jsonb :metadata, default: {}
      t.datetime :expires_at, null: false

      t.timestamps

      t.index :expires_at
      t.index [:user_profile_id, :created_at]
    end
  end
end