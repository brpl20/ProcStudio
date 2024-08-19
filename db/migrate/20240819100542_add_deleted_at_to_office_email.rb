class AddDeletedAtToOfficeEmail < ActiveRecord::Migration[7.0]
  def change
    add_column :office_emails, :deleted_at, :datetime
    add_index :office_emails, :deleted_at
  end
end
