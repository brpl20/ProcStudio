class CreateProfileClients < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_clients do |t|
      t.integer :role
      t.string :name
      t.string :lastname
      t.integer :gender
      t.string :rg
      t.string :cpf
      t.string :nationality
      t.integer :civil_status
      t.integer :capacity
      t.string :profession
      t.string :company
      t.date :birth
      t.string :monther_name
      t.string :number_benefit
      t.integer :status
      t.json :document
      t.string :nit
      t.string :inss_password
      t.integer :invalid_person
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
