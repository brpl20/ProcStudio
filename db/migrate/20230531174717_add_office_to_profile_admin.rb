class AddOfficeToProfileAdmin < ActiveRecord::Migration[7.0]
  def change
    add_reference :profile_admins, :office, null: false, foreign_key: true, default: 1
  end
end
