# frozen_string_literal: true

class CreateWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :works do |t|
      t.string :procedure
      t.string :subject
      t.string :action
      t.integer :number
      t.string :rate_percentage
      t.string :rate_percentage_exfield
      t.string :rate_fixed
      t.string :rate_parceled_exfield
      t.string :folder
      t.string :initial_atendee
      t.string :note
      t.string :checklist
      t.string :pending_document

      t.timestamps
    end
  end
end
