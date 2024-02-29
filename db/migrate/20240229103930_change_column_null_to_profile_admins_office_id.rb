class ChangeColumnNullToProfileAdminsOfficeId < ActiveRecord::Migration[7.0]
  def change
    change_column :profile_admins, :office_id, :bigint, null: true
  end
end
