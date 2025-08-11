class RemoveDeprecatedFieldsFromLegalEntity < ActiveRecord::Migration[7.0]
  def change
    # Remove deprecated fields that have been moved to LegalEntityOffice
    remove_column :legal_entities, :oab_id, :string
    remove_column :legal_entities, :society_link, :string
    remove_column :legal_entities, :inscription_number, :string
  end
end
