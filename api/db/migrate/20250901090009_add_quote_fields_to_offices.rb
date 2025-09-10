# frozen_string_literal: true

class AddQuoteFieldsToOffices < ActiveRecord::Migration[8.0]
  def change
    add_column :offices, :quote_value, :decimal, precision: 10, scale: 2, comment: 'Value per quote in BRL'
    add_column :offices, :number_of_quotes, :integer, default: 0, comment: 'Total number of quotes'
  end
end
