class CreateOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :offices do |t|
      t.string :name
      t.string :cnpj
      t.string :society
      t.date :foundation
      t.string :site
      t.string :street
      t.integer :number
      t.string :neighborhood
      t.string :city
      t.string :state
      t.references :office_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
