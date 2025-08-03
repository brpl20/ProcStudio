class CreateLegalEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :legal_entities do |t|
      t.string :name, null: false
      t.string :cnpj
      t.string :inscription_number
      t.string :state_registration
      t.string :oab_id
      t.string :society_link
      t.integer :number_of_partners
      t.string :status, default: 'active'
      t.string :accounting_type
      t.string :entity_type # 'law_firm', 'company', 'office'
      t.references :legal_representative, null: true, 
                   foreign_key: { to_table: :individual_entities }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :legal_entities, :cnpj, unique: true, where: "cnpj IS NOT NULL"
    add_index :legal_entities, :entity_type
    add_index :legal_entities, :deleted_at
    add_index :legal_entities, :status
  end
end
