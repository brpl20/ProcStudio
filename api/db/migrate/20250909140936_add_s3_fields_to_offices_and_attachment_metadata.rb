# frozen_string_literal: true

class AddS3FieldsToOfficesAndAttachmentMetadata < ActiveRecord::Migration[8.0]
  def change
    # Add S3 key field to offices for logo
    add_column :offices, :logo_s3_key, :string
    add_index :offices, :logo_s3_key

    # Add S3 fields to office_attachment_metadata
    add_column :office_attachment_metadata, :s3_key, :string
    add_column :office_attachment_metadata, :filename, :string
    add_column :office_attachment_metadata, :content_type, :string
    add_column :office_attachment_metadata, :byte_size, :bigint

    add_index :office_attachment_metadata, :s3_key
    add_index :office_attachment_metadata, :document_type

    # Remove blob_id as we're not using ActiveStorage anymore
    return unless column_exists?(:office_attachment_metadata, :blob_id)

    remove_column :office_attachment_metadata, :blob_id, :bigint
  end
end
