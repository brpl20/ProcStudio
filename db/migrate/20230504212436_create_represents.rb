class CreateRepresents < ActiveRecord::Migration[7.0]
  def change
    create_table :represents do |t|
      t.integer :represented_id
      t.references :profile_customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
