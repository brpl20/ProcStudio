class CreateLegalEntityOfficeRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :legal_entity_office_relationships do |t|
      t.references :legal_entity_office, foreign_key: true, null: false, index: { name: 'idx_office_rel_on_office_id' }
      t.references :lawyer, foreign_key: { to_table: :individual_entities }, null: false, index: { name: 'idx_office_rel_on_lawyer_id' }
      t.string :partnership_type
      t.decimal :ownership_percentage, precision: 5, scale: 2
      t.timestamps
    end

    add_index :legal_entity_office_relationships, :partnership_type, name: 'idx_office_rel_on_partnership'
    add_index :legal_entity_office_relationships, [:legal_entity_office_id, :lawyer_id], unique: true, name: 'idx_office_lawyer_unique'
  end
end
