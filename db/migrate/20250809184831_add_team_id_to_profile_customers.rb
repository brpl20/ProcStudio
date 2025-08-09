class AddTeamIdToProfileCustomers < ActiveRecord::Migration[7.0]
  def change
    add_reference :profile_customers, :team, null: true, foreign_key: true
  end
end
