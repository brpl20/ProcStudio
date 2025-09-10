class ChangeInitialAtendeeToInteger < ActiveRecord::Migration[7.0]
  def change
    remove_column :works, :initial_atendee
    add_column :works, :initial_atendee, :integer
  end
end
