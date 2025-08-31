# frozen_string_literal: true

class UpdateLegalCostEntryToUseLegalCostType < ActiveRecord::Migration[8.0]
  def change
    add_reference :legal_cost_entries, :legal_cost_type, foreign_key: true, null: true

    # Remove the old cost_type column after data migration
    # We'll keep it temporarily for data migration
    # remove_column :legal_cost_entries, :cost_type, :string
  end
end
