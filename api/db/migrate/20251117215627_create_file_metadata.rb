class CreateFileMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :file_metadata do |t|
      t.references :attachable, polymorphic: true, null: false, index: true
      t.string :s3_key, null: false
      t.string :filename, null: false
      t.string :content_type, null: false
      t.bigint :byte_size, null: false
      t.string :checksum, null: false
      t.boolean :created_by_system, default: false, null: false
      t.string :file_category
      t.references :uploaded_by, foreign_key: { to_table: :user_profiles }
      t.jsonb :metadata, default: {}
      t.datetime :uploaded_at, null: false
      t.datetime :expires_at

      t.timestamps

      t.index :s3_key, unique: true
      t.index :checksum
      t.index :created_by_system
      t.index :file_category
      t.index :uploaded_at
      t.index :expires_at
      t.index [:attachable_type, :attachable_id, :file_category],
              name: 'index_file_metadata_on_attachable_and_category'
    end
  end
end