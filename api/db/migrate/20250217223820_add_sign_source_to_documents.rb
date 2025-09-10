class AddSignSourceToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :sign_source, :integer, default: 0, null: false

    # Removed data update - can't use models during migration
  end
end
