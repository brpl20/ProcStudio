# frozen_string_literal: true

class UpdateHonorariesStructure < ActiveRecord::Migration[8.0]
  def change
    # Add procedure reference and make work_id optional
    add_reference :honoraries, :procedure, foreign_key: true, null: true

    # Make work_id nullable since honorary can be attached to procedure instead
    change_column_null :honoraries, :work_id, true

    # Add missing fields to honoraries table
    add_column :honoraries, :name, :string unless column_exists?(:honoraries, :name)
    add_column :honoraries, :description, :text unless column_exists?(:honoraries, :description)
    add_column :honoraries, :status, :string, default: 'active' unless column_exists?(:honoraries, :status)
    add_column :honoraries, :deleted_at, :datetime unless column_exists?(:honoraries, :deleted_at)

    # Add indexes
    add_index :honoraries, :deleted_at unless index_exists?(:honoraries, :deleted_at)
    add_index :honoraries, :status unless index_exists?(:honoraries, :status)
    add_index :honoraries, [:work_id, :procedure_id] unless index_exists?(:honoraries, [:work_id, :procedure_id])

    # Add check constraint to ensure honorary is attached to either work or procedure
    execute <<-SQL.squish
      ALTER TABLE honoraries ADD CONSTRAINT check_honorary_attachment#{' '}
      CHECK ((work_id IS NOT NULL AND procedure_id IS NULL) OR#{' '}
             (work_id IS NOT NULL AND procedure_id IS NOT NULL))
    SQL
  end
end
