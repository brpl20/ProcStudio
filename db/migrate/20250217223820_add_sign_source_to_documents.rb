class AddSignSourceToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :sign_source, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Document.where.not(status: :signed).update_all(sign_source: 0)

        Document.where(status: :signed).where(sign_source: 0).update_all(sign_source: 1)
      end

      dir.down do
        remove_column :documents, :sign_source
      end
    end
  end
end
