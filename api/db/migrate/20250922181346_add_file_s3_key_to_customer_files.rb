class AddFileS3KeyToCustomerFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :customer_files, :file_s3_key, :string
  end
end
