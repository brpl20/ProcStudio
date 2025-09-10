# frozen_string_literal: true

class UpdateRepresentsForMultipleRepresentors < ActiveRecord::Migration[8.0]
  def change
    # Add new columns to support multiple representors and better tracking
    add_column :represents, :relationship_type, :string, default: 'representation'
    add_column :represents, :active, :boolean, default: true, null: false
    add_column :represents, :start_date, :date
    add_column :represents, :end_date, :date
    add_column :represents, :notes, :text
    add_column :represents, :team_id, :bigint

    # Add indexes for better performance
    add_index :represents, :relationship_type
    add_index :represents, :active
    add_index :represents, :team_id
    add_index :represents, [:profile_customer_id, :active]
    add_index :represents, [:representor_id, :active]

    # Add foreign key for team
    add_foreign_key :represents, :teams

    # Remove unique constraint if it exists (to allow multiple representors)
    # Note: If there's a unique index on profile_customer_id, we need to remove it
    # to allow multiple representors per customer
  end
end
