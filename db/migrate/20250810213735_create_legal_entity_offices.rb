class CreateLegalEntityOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :legal_entity_offices do |t|
      t.references :legal_entity, foreign_key: true, null: false
      t.string :oab_id
      t.string :inscription_number
      t.string :society_link
      t.string :legal_specialty
      t.references :team, foreign_key: true
      t.timestamps
    end

    add_index :legal_entity_offices, :oab_id
  end
end
