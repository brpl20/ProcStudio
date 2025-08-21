# frozen_string_literal: true

class RemoveSubjectFromWorks < ActiveRecord::Migration[8.0]
  def change
    # Remove the deprecated subject column now that law_area_id is in use
    remove_column :works, :subject, :string
  end
end
