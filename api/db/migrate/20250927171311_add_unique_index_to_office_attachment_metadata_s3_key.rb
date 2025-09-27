# frozen_string_literal: true

class AddUniqueIndexToOfficeAttachmentMetadataS3Key < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing non-unique index
    remove_index :office_attachment_metadata, :s3_key

    # Add a unique index
    add_index :office_attachment_metadata, :s3_key, unique: true
  end
end
