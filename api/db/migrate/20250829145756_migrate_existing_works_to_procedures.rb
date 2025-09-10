# frozen_string_literal: true

class MigrateExistingWorksToProcedures < ActiveRecord::Migration[8.0]
  def up
    # Migrate existing Works to have at least one Procedure
    Work.find_each do |work|
      # Skip if work already has procedures
      next if work.procedures.any?

      # Create a procedure based on existing work data
      # Skip checking for old procedure field since it's been removed
      procedure_type = 'administrativo' # Default type

      # Skip checking for old status field since it's been removed
      status = 'in_progress' # Default status

      procedure_attrs = {
        procedure_type: procedure_type,
        status: status,
        law_area_id: work.law_area_id,
        start_date: work.created_at.to_date
      }

      procedure_attrs[:number] = work.number.to_s if work.respond_to?(:number) && work.number.present?
      procedure_attrs[:notes] = work.note if work.respond_to?(:note) && work.note.present?

      procedure = work.procedures.create!(procedure_attrs)

      # Migrate existing honoraries to be attached to the work (global level)
      # Since the relationship changed from has_one to has_many,
      # existing honoraries should already have work_id set
      work.honoraries.update_all(procedure_id: nil)

      Rails.logger.debug { "Migrated Work ##{work.id} to have Procedure ##{procedure.id}" }
    end
  end

  def down
    # In development/testing, we can safely remove procedures created by this migration
    # In production, this should remain irreversible
    raise ActiveRecord::IrreversibleMigration unless Rails.env.local?

    Rails.logger.debug 'Rolling back procedures created from migration...'
    # This will cascade delete related data due to dependent: :destroy
    Procedure.destroy_all
  end
end
