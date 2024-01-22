class RemoveProfileAdminFromRepresents < ActiveRecord::Migration[7.0]
  def up
    remove_reference :represents, :profile_admin, null: false, foreign_key: true
    add_column :represents, :representor_id, :bigint
    add_index :represents, :representor_id
    add_foreign_key :represents, :profile_customers, column: :representor_id
  end

  def down
    add_reference :represents, :profile_admin, null: true, foreign_key: true
    remove_column :represents, :representor_id, :bigint
  end
end
