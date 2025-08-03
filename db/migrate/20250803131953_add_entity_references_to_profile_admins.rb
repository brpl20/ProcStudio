class AddEntityReferencesToProfileAdmins < ActiveRecord::Migration[7.0]
  def change
    add_reference :profile_admins, :individual_entity, null: true, foreign_key: true
    add_reference :profile_admins, :legal_entity, null: true, foreign_key: true
  end
end
