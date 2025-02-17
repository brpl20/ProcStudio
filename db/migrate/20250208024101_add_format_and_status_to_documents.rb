class AddFormatAndStatusToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :format, :integer, default: 0, null: false
    add_column :documents, :status, :integer, default: 0, null: false
  end
end
