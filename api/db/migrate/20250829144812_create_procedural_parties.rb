# frozen_string_literal: true

class CreateProceduralParties < ActiveRecord::Migration[8.0]
  def change
    create_table :procedural_parties do |t|
      t.references :procedure, null: false, foreign_key: true

      # Party type: plaintiff or defendant
      t.string :party_type, null: false # 'plaintiff' or 'defendant'

      # Polymorphic association for known customers or simple name for unknown parties
      t.references :partyable, polymorphic: true # Can be ProfileCustomer or nil

      # For parties that are not in our system (just names)
      t.string :name # Used when partyable is nil
      t.string :cpf_cnpj # Optional identification
      t.string :oab_number # For lawyers

      # Additional party information
      t.boolean :is_primary, default: false # Main plaintiff/defendant
      t.integer :position # Order in the party list

      # Representation information
      t.string :represented_by # Lawyer or representative name
      t.text :notes

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :procedural_parties, :party_type
    add_index :procedural_parties, [:procedure_id, :party_type]
    add_index :procedural_parties, [:partyable_type, :partyable_id]
    add_index :procedural_parties, :deleted_at
    add_index :procedural_parties, :cpf_cnpj
  end
end
