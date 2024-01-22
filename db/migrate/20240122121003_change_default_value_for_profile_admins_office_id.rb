class ChangeDefaultValueForProfileAdminsOfficeId < ActiveRecord::Migration[7.0]
  def up
    change_column_default :profile_admins, :office_id, nil
  end

  def down
    change_column_default :profile_admins, :office_id, 1
  end
end
