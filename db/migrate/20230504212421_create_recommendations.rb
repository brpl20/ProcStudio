class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.decimal :percentage
      t.decimal :commition
      t.references :profile_customer, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
