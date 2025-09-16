# frozen_string_literal: true

class MakeDraftableOptionalInDrafts < ActiveRecord::Migration[8.0]
  def change
    # Make draftable_id optional to allow drafts for new records
    change_column_null :drafts, :draftable_id, true
    
    # Remove existing unique index if it exists
    if index_exists?(:drafts, [:team_id, :draftable_type, :draftable_id, :form_type], name: 'index_drafts_unique_form_with_team')
      remove_index :drafts, name: 'index_drafts_unique_form_with_team'
    end
    
    # Add new index that allows multiple drafts with null draftable_id
    # For existing records, enforce uniqueness
    add_index :drafts, [:team_id, :draftable_type, :draftable_id, :form_type], 
              unique: true, 
              where: 'draftable_id IS NOT NULL',
              name: 'index_drafts_unique_existing_records'
              
    # For new records, allow multiple drafts per user/form_type
    add_index :drafts, [:team_id, :user_id, :form_type, :draftable_type],
              where: 'draftable_id IS NULL',
              name: 'index_drafts_new_records'
  end
end