class AddCapacityToIndividualEntities < ActiveRecord::Migration[7.0]
  def change
    add_column :individual_entities, :capacity, :string, default: 'able'
    add_index :individual_entities, :capacity
    
    # Set default capacity for existing records
    reversible do |dir|
      dir.up do
        execute "UPDATE individual_entities SET capacity = 'able' WHERE capacity IS NULL"
      end
    end
  end
end
