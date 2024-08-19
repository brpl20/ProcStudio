class AddDeletedAtToRecommendation < ActiveRecord::Migration[7.0]
  def change
    add_column :recommendations, :deleted_at, :datetime
    add_index :recommendations, :deleted_at
  end
end
