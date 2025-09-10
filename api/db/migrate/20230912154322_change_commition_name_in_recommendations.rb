class ChangeCommitionNameInRecommendations < ActiveRecord::Migration[7.0]
  def change
    rename_column :recommendations, :commition, :commission
  end
end
