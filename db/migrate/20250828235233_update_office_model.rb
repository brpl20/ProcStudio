# frozen_string_literal: true

class UpdateOfficeModel < ActiveRecord::Migration[8.0]
  def change
    # Rename oab to oab_id
    rename_column :offices, :oab, :oab_id

    # Add new fields
    add_column :offices, :oab_status, :string
    add_column :offices, :oab_inscricao, :string
    add_column :offices, :oab_link, :string
    add_column :offices, :created_by_id, :bigint
    add_column :offices, :deleted_by_id, :bigint

    # Remove office_type_id and responsible_lawyer_id
    remove_column :offices, :office_type_id
    remove_column :offices, :responsible_lawyer_id

    # Add indexes
    add_index :offices, :created_by_id
    add_index :offices, :deleted_by_id

    # Add foreign keys
    add_foreign_key :offices, :users, column: :created_by_id
    add_foreign_key :offices, :users, column: :deleted_by_id
  end
end
