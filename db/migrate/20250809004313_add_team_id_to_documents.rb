class AddTeamIdToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_reference :documents, :team, null: true, foreign_key: true
  end
end
