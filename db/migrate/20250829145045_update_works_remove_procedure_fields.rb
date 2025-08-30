# frozen_string_literal: true

class UpdateWorksRemoveProcedureFields < ActiveRecord::Migration[8.0]
  def change
    # Remove procedure-specific fields that are moving to Procedures table
    remove_column :works, :procedure, :string if column_exists?(:works, :procedure)
    remove_column :works, :procedures, :text if column_exists?(:works, :procedures)
    remove_column :works, :status, :string if column_exists?(:works, :status)

    # Add a general status for Work (different from procedure status)
    add_column :works, :work_status, :string, default: 'active' unless column_exists?(:works, :work_status)

    # Add index for work_status
    add_index :works, :work_status unless index_exists?(:works, :work_status)
  end
end
