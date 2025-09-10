# frozen_string_literal: true

class CreateDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :drafts do |t|
      t.references :draftable, polymorphic: true, null: false
      t.references :user, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :form_type, null: false
      t.json :data, null: false
      t.string :status, default: 'draft'
      t.datetime :expires_at
      t.timestamps
    end

    add_index :drafts, [:draftable_type, :draftable_id, :form_type], unique: true, name: 'index_drafts_unique_form'
    add_index :drafts, :expires_at
    add_index :drafts, :status
  end
end
