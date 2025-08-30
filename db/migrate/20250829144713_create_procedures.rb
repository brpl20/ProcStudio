# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[8.0]
  def change
    create_table :procedures do |t|
      t.references :work, null: false, foreign_key: true
      t.references :law_area, foreign_key: true

      # Hierarchical structure support (for child procedures)
      t.string :ancestry
      t.index :ancestry

      # Basic procedure information
      t.string :procedure_type, null: false # 'administrativo', 'judicial', 'extrajudicial'
      t.string :number # Procedure number (judicial or administrative)

      # Location information
      t.string :city
      t.string :state

      # System and competence
      t.string :system # INSS, Eproc, Projudi, ECAC, Incra, etc.
      t.string :competence # Justiça Federal, Justiça do Trabalho, INSS, etc.

      # Dates
      t.date :start_date
      t.date :end_date

      # Classification and responsible
      t.string :procedure_class # Pequenas Causas, Rito Extraordinário, etc.
      t.string :responsible # Judge name, auditor, etc.

      # Financial values
      t.decimal :claim_value, precision: 15, scale: 2 # Valor da Causa
      t.decimal :conviction_value, precision: 15, scale: 2 # Valor da Condenação
      t.decimal :received_value, precision: 15, scale: 2 # Valor recebido

      # Status and flags
      t.string :status, default: 'in_progress' # in_progress, paused, completed, archived
      t.boolean :justice_free, default: false # Justiça gratuita
      t.boolean :conciliation, default: false # Interesse em conciliação

      # Priority configuration
      t.boolean :priority, default: false
      t.string :priority_type # age, sickness, disability, etc.

      # Notes
      t.text :notes

      # Soft delete support
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :procedures, :procedure_type
    add_index :procedures, :status
    add_index :procedures, :deleted_at
    add_index :procedures, :number
    add_index :procedures, :system
    add_index :procedures, :competence
    add_index :procedures, [:work_id, :procedure_type]
  end
end
