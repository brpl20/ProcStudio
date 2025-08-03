class CreateIndividualEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :individual_entities do |t|
      t.string :name, null: false
      t.string :last_name
      t.string :gender
      t.string :rg
      t.string :cpf, null: false
      t.string :nationality
      t.string :civil_status
      t.string :profession
      t.date :birth
      t.string :mother_name
      t.string :nit
      t.string :inss_password
      t.boolean :invalid_person, default: false
      t.json :additional_documents, default: {}
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :individual_entities, :cpf, unique: true
    add_index :individual_entities, :deleted_at
    add_index :individual_entities, [:name, :last_name]
  end
end
