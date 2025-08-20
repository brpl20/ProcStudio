# frozen_string_literal: true

class UpdatePowersToUseLawAreaId < ActiveRecord::Migration[8.0]
  def change
    # Adicionar referência para law_area
    add_reference :powers, :law_area, foreign_key: true, null: true

    # Atualizar índices
    add_index :powers, [:category, :law_area_id]
  end
end
