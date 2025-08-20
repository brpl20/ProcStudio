# frozen_string_literal: true

class RestructurePowersForProceduresAndLawAreas < ActiveRecord::Migration[8.0]
  def change
    # Add new columns for law area and team customization
    add_column :powers, :law_area, :string
    add_column :powers, :is_base, :boolean, default: false, null: false
    add_column :powers, :created_by_team_id, :bigint

    # Add indexes for better query performance
    add_index :powers, [:category, :law_area]
    add_index :powers, :is_base
    add_index :powers, :created_by_team_id

    # Add foreign key for team that created custom powers
    add_foreign_key :powers, :teams, column: :created_by_team_id
  end
end
