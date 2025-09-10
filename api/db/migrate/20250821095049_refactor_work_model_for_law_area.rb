# frozen_string_literal: true

class RefactorWorkModelForLawArea < ActiveRecord::Migration[8.0]
  def change
    # Add law_area reference
    add_reference :works, :law_area, foreign_key: true, index: true

    # Remove deprecated area-specific columns (will be handled by LawArea)
    remove_column :works, :civel_area, :string
    remove_column :works, :tributary_areas, :string
    remove_column :works, :social_security_areas, :string
    remove_column :works, :laborite_areas, :string

    # Subject will be replaced by law_area, but let's keep it temporarily for data migration
    # remove_column :works, :subject, :string # Will be removed in a separate migration after data migration
  end
end
