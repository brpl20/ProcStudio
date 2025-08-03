class AddTeamToOffices < ActiveRecord::Migration[7.0]
  def change
    add_reference :offices, :team, null: true, foreign_key: true
    
    # For test data, we'll allow null values initially
    # In production, you would migrate existing offices to teams here
  end
end
