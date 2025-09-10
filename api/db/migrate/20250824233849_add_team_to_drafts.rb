# frozen_string_literal: true

class AddTeamToDrafts < ActiveRecord::Migration[8.0]
  def change
    add_reference :drafts, :team, foreign_key: true, index: true

    # Update the unique index to include team_id for proper scoping
    remove_index :drafts, name: 'index_drafts_unique_form' if index_name_exists?(:drafts, 'index_drafts_unique_form')
    add_index :drafts, [:team_id, :draftable_type, :draftable_id, :form_type],
              unique: true,
              name: 'index_drafts_unique_form_with_team'
  end
end
