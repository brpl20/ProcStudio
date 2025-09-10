# frozen_string_literal: true

class RemoveLawAreaStringFromPowers < ActiveRecord::Migration[8.0]
  def change
    # Remove o índice antigo primeiro
    remove_index :powers, [:category, :law_area] if index_exists?(:powers, [:category, :law_area])

    # Remove a coluna law_area string
    remove_column :powers, :law_area, :string
  end
end
