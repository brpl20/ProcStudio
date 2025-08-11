class MigrateContactDataToPolymorphicModels < ActiveRecord::Migration[7.0]
  def up
    puts "Starting contact data migration to polymorphic models..."
    
    # Temporarily define old models to avoid dependency issues
    admin_address_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'admin_addresses'
    end
    
    admin_phone_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'admin_phones'
    end
    
    admin_email_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'admin_emails'
    end
    
    admin_bank_account_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'admin_bank_accounts'
    end
    
    customer_address_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customer_addresses'
    end
    
    customer_phone_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customer_phones'
    end
    
    customer_email_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customer_emails'
    end
    
    customer_bank_account_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'customer_bank_accounts'
    end
    
    contact_info_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'contact_infos'
    end
    
    contact_address_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'contact_addresses'
    end
    
    contact_phone_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'contact_phones'
    end
    
    contact_email_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'contact_emails'
    end
    
    contact_bank_account_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'contact_bank_accounts'
    end
    
    # Migration counters
    migrated_count = { addresses: 0, phones: 0, emails: 0, bank_accounts: 0 }
    
    # 1. Migrate Admin legacy contacts to polymorphic models
    puts "Migrating Admin contact data..."
    
    # Admin Addresses
    if table_exists?('admin_addresses')
      admin_address_class.find_each do |admin_address|
        begin
          # Find the associated admin through profile_admin
          profile_admin = ProfileAdmin.find_by(admin_id: admin_address.admin_id)
          next unless profile_admin&.individual_entity_id
          
          individual_entity = IndividualEntity.find_by(id: profile_admin.individual_entity_id)
          next unless individual_entity
          
          contact_address_class.create!(
            contactable_type: 'IndividualEntity',
            contactable_id: individual_entity.id,
            street: admin_address.street || 'N/A',
            number: admin_address.number || 'S/N',
            complement: admin_address.complement,
            neighborhood: admin_address.neighborhood,
            city: admin_address.city || 'N/A',
            state: admin_address.state || 'N/A',
            zip_code: admin_address.zip_code&.gsub(/\D/, '') || '00000000',
            country: admin_address.country || 'Brasil',
            is_primary: true
          )
          migrated_count[:addresses] += 1
        rescue => e
          puts "Error migrating admin address #{admin_address.id}: #{e.message}"
        end
      end
    end
    
    # Admin Phones
    if table_exists?('admin_phones')
      admin_phone_class.find_each do |admin_phone|
        begin
          profile_admin = ProfileAdmin.find_by(admin_id: admin_phone.admin_id)
          next unless profile_admin&.individual_entity_id
          
          individual_entity = IndividualEntity.find_by(id: profile_admin.individual_entity_id)
          next unless individual_entity
          
          contact_phone_class.create!(
            contactable_type: 'IndividualEntity',
            contactable_id: individual_entity.id,
            number: admin_phone.number&.gsub(/\D/, '') || '11999999999',
            phone_type: admin_phone.phone_type || 'mobile',
            is_primary: true,
            is_whatsapp: admin_phone.respond_to?(:is_whatsapp) ? admin_phone.is_whatsapp : false
          )
          migrated_count[:phones] += 1
        rescue => e
          puts "Error migrating admin phone #{admin_phone.id}: #{e.message}"
        end
      end
    end
    
    # Admin Emails
    if table_exists?('admin_emails')
      admin_email_class.find_each do |admin_email|
        begin
          profile_admin = ProfileAdmin.find_by(admin_id: admin_email.admin_id)
          next unless profile_admin&.individual_entity_id
          
          individual_entity = IndividualEntity.find_by(id: profile_admin.individual_entity_id)
          next unless individual_entity
          
          contact_email_class.create!(
            contactable_type: 'IndividualEntity',
            contactable_id: individual_entity.id,
            address: admin_email.email || "admin#{admin_email.id}@example.com",
            email_type: admin_email.email_type || 'work',
            is_primary: true,
            is_verified: false
          )
          migrated_count[:emails] += 1
        rescue => e
          puts "Error migrating admin email #{admin_email.id}: #{e.message}"
        end
      end
    end
    
    # Admin Bank Accounts
    if table_exists?('admin_bank_accounts')
      admin_bank_account_class.find_each do |admin_bank|
        begin
          profile_admin = ProfileAdmin.find_by(admin_id: admin_bank.admin_id)
          next unless profile_admin&.individual_entity_id
          
          individual_entity = IndividualEntity.find_by(id: profile_admin.individual_entity_id)
          next unless individual_entity
          
          contact_bank_account_class.create!(
            contactable_type: 'IndividualEntity',
            contactable_id: individual_entity.id,
            bank_name: admin_bank.bank_name || 'Banco desconhecido',
            bank_code: admin_bank.bank_code&.gsub(/\D/, '') || '001',
            agency: admin_bank.agency || '0001',
            account_number: admin_bank.account_number || '00000-0',
            account_type: admin_bank.account_type || 'checking',
            pix_key: admin_bank.respond_to?(:pix_key) ? admin_bank.pix_key : nil,
            is_primary: true
          )
          migrated_count[:bank_accounts] += 1
        rescue => e
          puts "Error migrating admin bank account #{admin_bank.id}: #{e.message}"
        end
      end
    end
    
    # 2. Migrate Customer legacy contacts to polymorphic models
    puts "Migrating Customer contact data..."
    
    # Customer Addresses  
    if table_exists?('customer_addresses')
      customer_address_class.find_each do |customer_address|
        begin
          customer = Customer.find_by(id: customer_address.customer_id)
          next unless customer&.profile
          
          contact_address_class.create!(
            contactable_type: customer.profile_type,
            contactable_id: customer.profile_id,
            street: customer_address.street || 'N/A',
            number: customer_address.number || 'S/N',
            complement: customer_address.complement,
            neighborhood: customer_address.neighborhood,
            city: customer_address.city || 'N/A',
            state: customer_address.state || 'N/A',
            zip_code: customer_address.zip_code&.gsub(/\D/, '') || '00000000',
            country: customer_address.country || 'Brasil',
            is_primary: true
          )
          migrated_count[:addresses] += 1
        rescue => e
          puts "Error migrating customer address #{customer_address.id}: #{e.message}"
        end
      end
    end
    
    # Customer Phones
    if table_exists?('customer_phones')
      customer_phone_class.find_each do |customer_phone|
        begin
          customer = Customer.find_by(id: customer_phone.customer_id)
          next unless customer&.profile
          
          contact_phone_class.create!(
            contactable_type: customer.profile_type,
            contactable_id: customer.profile_id,
            number: customer_phone.number&.gsub(/\D/, '') || '11999999999',
            phone_type: customer_phone.phone_type || 'mobile',
            is_primary: true,
            is_whatsapp: customer_phone.respond_to?(:is_whatsapp) ? customer_phone.is_whatsapp : false
          )
          migrated_count[:phones] += 1
        rescue => e
          puts "Error migrating customer phone #{customer_phone.id}: #{e.message}"
        end
      end
    end
    
    # Customer Emails
    if table_exists?('customer_emails')
      customer_email_class.find_each do |customer_email|
        begin
          customer = Customer.find_by(id: customer_email.customer_id)
          next unless customer&.profile
          
          contact_email_class.create!(
            contactable_type: customer.profile_type,
            contactable_id: customer.profile_id,
            address: customer_email.email || "customer#{customer_email.id}@example.com",
            email_type: customer_email.email_type || 'personal',
            is_primary: true,
            is_verified: false
          )
          migrated_count[:emails] += 1
        rescue => e
          puts "Error migrating customer email #{customer_email.id}: #{e.message}"
        end
      end
    end
    
    # Customer Bank Accounts
    if table_exists?('customer_bank_accounts')
      customer_bank_account_class.find_each do |customer_bank|
        begin
          customer = Customer.find_by(id: customer_bank.customer_id)
          next unless customer&.profile
          
          contact_bank_account_class.create!(
            contactable_type: customer.profile_type,
            contactable_id: customer.profile_id,
            bank_name: customer_bank.bank_name || 'Banco desconhecido',
            bank_code: customer_bank.bank_code&.gsub(/\D/, '') || '001',
            agency: customer_bank.agency || '0001',
            account_number: customer_bank.account_number || '00000-0',
            account_type: customer_bank.account_type || 'checking',
            pix_key: customer_bank.respond_to?(:pix_key) ? customer_bank.pix_key : nil,
            is_primary: true
          )
          migrated_count[:bank_accounts] += 1
        rescue => e
          puts "Error migrating customer bank account #{customer_bank.id}: #{e.message}"
        end
      end
    end
    
    # 3. Migrate ContactInfo JSON data to structured models
    puts "Migrating ContactInfo JSON data..."
    
    if table_exists?('contact_infos')
      contact_info_class.where(contact_type: 'address').find_each do |contact_info|
        begin
          data = contact_info.contact_data || {}
          contact_address_class.create!(
            contactable_type: contact_info.contactable_type,
            contactable_id: contact_info.contactable_id,
            street: data['street'] || 'N/A',
            number: data['number'] || 'S/N',
            complement: data['complement'],
            neighborhood: data['neighborhood'],
            city: data['city'] || 'N/A',
            state: data['state'] || 'N/A',
            zip_code: data['zip_code']&.gsub(/\D/, '') || '00000000',
            country: data['country'] || 'Brasil',
            is_primary: contact_info.is_primary || false
          )
          migrated_count[:addresses] += 1
        rescue => e
          puts "Error migrating ContactInfo address #{contact_info.id}: #{e.message}"
        end
      end
      
      contact_info_class.where(contact_type: 'phone').find_each do |contact_info|
        begin
          data = contact_info.contact_data || {}
          number = data['number'] || data['phone_number'] || data['phone'] || '11999999999'
          
          contact_phone_class.create!(
            contactable_type: contact_info.contactable_type,
            contactable_id: contact_info.contactable_id,
            number: number.gsub(/\D/, ''),
            phone_type: data['type'] || data['phone_type'] || 'mobile',
            is_primary: contact_info.is_primary || false,
            is_whatsapp: data['is_whatsapp'] || false
          )
          migrated_count[:phones] += 1
        rescue => e
          puts "Error migrating ContactInfo phone #{contact_info.id}: #{e.message}"
        end
      end
      
      contact_info_class.where(contact_type: 'email').find_each do |contact_info|
        begin
          data = contact_info.contact_data || {}
          email_address = data['address'] || data['email'] || "contact#{contact_info.id}@example.com"
          
          contact_email_class.create!(
            contactable_type: contact_info.contactable_type,
            contactable_id: contact_info.contactable_id,
            address: email_address,
            email_type: data['type'] || data['email_type'] || 'personal',
            is_primary: contact_info.is_primary || false,
            is_verified: data['is_verified'] || false
          )
          migrated_count[:emails] += 1
        rescue => e
          puts "Error migrating ContactInfo email #{contact_info.id}: #{e.message}"
        end
      end
      
      contact_info_class.where(contact_type: 'bank_account').find_each do |contact_info|
        begin
          data = contact_info.contact_data || {}
          
          contact_bank_account_class.create!(
            contactable_type: contact_info.contactable_type,
            contactable_id: contact_info.contactable_id,
            bank_name: data['bank_name'] || 'Banco desconhecido',
            bank_code: data['bank_code']&.gsub(/\D/, '') || '001',
            agency: data['agency'] || '0001',
            account_number: data['account_number'] || '00000-0',
            account_type: data['account_type'] || 'checking',
            pix_key: data['pix_key'],
            is_primary: contact_info.is_primary || false
          )
          migrated_count[:bank_accounts] += 1
        rescue => e
          puts "Error migrating ContactInfo bank account #{contact_info.id}: #{e.message}"
        end
      end
    end
    
    puts "Migration completed!"
    puts "Addresses migrated: #{migrated_count[:addresses]}"
    puts "Phones migrated: #{migrated_count[:phones]}"
    puts "Emails migrated: #{migrated_count[:emails]}"
    puts "Bank accounts migrated: #{migrated_count[:bank_accounts]}"
  end

  def down
    puts "Rolling back contact data migration..."
    
    ContactAddress.delete_all
    ContactPhone.delete_all
    ContactEmail.delete_all
    ContactBankAccount.delete_all
    
    puts "Rollback completed - all new polymorphic contact data deleted"
  end
end