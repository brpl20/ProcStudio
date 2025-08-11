class MigrateLegalEntityDataToOffice < ActiveRecord::Migration[7.0]
  def up
    # Temporarily define models to avoid issues with model changes
    legal_entity_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'legal_entities'
    end
    
    legal_entity_office_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'legal_entity_offices'
    end
    
    # Find all legal entities that might be law offices (have OAB ID)
    legal_entity_class.where.not(oab_id: [nil, ""]).find_each do |legal_entity|
      # Create a new office record
      office = legal_entity_office_class.create!(
        legal_entity_id: legal_entity.id,
        oab_id: legal_entity.oab_id,
        inscription_number: legal_entity.inscription_number,
        society_link: legal_entity.society_link,
        team_id: legal_entity.respond_to?(:team_id) ? legal_entity.team_id : nil,
        created_at: legal_entity.created_at,
        updated_at: legal_entity.updated_at
      )
      
      puts "Created office for legal entity #{legal_entity.id} with OAB ID: #{legal_entity.oab_id}"
    end
  end

  def down
    # Temporarily define models
    legal_entity_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'legal_entities'
    end
    
    legal_entity_office_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'legal_entity_offices'
    end
    
    # Reverse migration if needed
    legal_entity_office_class.find_each do |office|
      legal_entity = legal_entity_class.find_by(id: office.legal_entity_id)
      if legal_entity
        legal_entity.update_columns(
          oab_id: office.oab_id,
          inscription_number: office.inscription_number,
          society_link: office.society_link
        )
        
        puts "Restored data to legal entity #{legal_entity.id}"
      end
    end
    
    # Delete all office records
    legal_entity_office_class.delete_all
  end
end
