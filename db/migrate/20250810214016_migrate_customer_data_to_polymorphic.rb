class MigrateCustomerDataToPolymorphic < ActiveRecord::Migration[7.0]
  def up
    # Temporarily define models to avoid issues with model changes
    customer_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customers'
    end
    
    profile_customer_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'profile_customers'
    end
    
    # Migrate data from ProfileCustomer to appropriate entities
    profile_customer_class.find_each do |profile|
      customer = customer_class.find_by(id: profile.customer_id)
      next unless customer
      
      if profile.individual_entity_id.present?
        # Link Customer to IndividualEntity
        customer.update_columns(
          profile_type: 'IndividualEntity',
          profile_id: profile.individual_entity_id
        )
        puts "Linked customer #{customer.id} to individual entity #{profile.individual_entity_id}"
      elsif profile.legal_entity_id.present?
        # Link Customer to LegalEntity
        customer.update_columns(
          profile_type: 'LegalEntity',
          profile_id: profile.legal_entity_id
        )
        puts "Linked customer #{customer.id} to legal entity #{profile.legal_entity_id}"
      else
        puts "Customer #{customer.id} has no entity association in ProfileCustomer"
      end
    end
  end

  def down
    # Reverse migration
    customer_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customers'
    end
    
    profile_customer_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'profile_customers'
    end
    
    customer_class.where.not(profile_type: nil).find_each do |customer|
      profile = profile_customer_class.find_or_initialize_by(customer_id: customer.id)
      
      if customer.profile_type == 'IndividualEntity'
        profile.individual_entity_id = customer.profile_id
        profile.legal_entity_id = nil
      elsif customer.profile_type == 'LegalEntity'
        profile.legal_entity_id = customer.profile_id
        profile.individual_entity_id = nil
      end
      
      # Set required fields if not present
      profile.customer_type ||= customer.profile_type == 'IndividualEntity' ? 'individual' : 'legal'
      profile.name ||= 'Migration Placeholder'
      profile.team_id ||= customer.team_id if customer.respond_to?(:team_id)
      
      profile.save!
      customer.update_columns(profile_type: nil, profile_id: nil)
      
      puts "Restored ProfileCustomer for customer #{customer.id}"
    end
  end
end
