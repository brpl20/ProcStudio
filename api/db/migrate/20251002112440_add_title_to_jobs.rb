# frozen_string_literal: true

class AddTitleToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :title, :string
  end
end
