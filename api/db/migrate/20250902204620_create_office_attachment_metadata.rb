# frozen_string_literal: true

class CreateOfficeAttachmentMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :office_attachment_metadata do |t|
      t.references :office, null: false, foreign_key: true
      t.bigint :blob_id, null: false
      t.date :document_date
      t.string :document_type # 'logo', 'social_contract', etc.
      t.string :description
      t.json :custom_metadata # For any additional metadata
      t.references :uploaded_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :office_attachment_metadata, :blob_id
    add_index :office_attachment_metadata, [:office_id, :document_type]

    # Add foreign key to active_storage_blobs
    add_foreign_key :office_attachment_metadata, :active_storage_blobs, column: :blob_id
  end
end
