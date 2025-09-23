class AddS3KeysToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :original_s3_key, :string
    add_column :documents, :signed_s3_key, :string
  end
end
