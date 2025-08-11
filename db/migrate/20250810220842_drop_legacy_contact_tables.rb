class DropLegacyContactTables < ActiveRecord::Migration[7.0]
  def up
    # Drop legacy admin contact tables
    drop_table :admin_addresses if table_exists?(:admin_addresses)
    drop_table :admin_phones if table_exists?(:admin_phones)
    drop_table :admin_emails if table_exists?(:admin_emails)
    drop_table :admin_bank_accounts if table_exists?(:admin_bank_accounts)
    
    # Drop legacy customer contact tables
    drop_table :customer_addresses if table_exists?(:customer_addresses)
    drop_table :customer_phones if table_exists?(:customer_phones)
    drop_table :customer_emails if table_exists?(:customer_emails)
    drop_table :customer_bank_accounts if table_exists?(:customer_bank_accounts)
    
    # Drop the old polymorphic ContactInfo table (JSON-based)
    drop_table :contact_infos if table_exists?(:contact_infos)
    
    # Drop legacy individual contact tables with CASCADE to handle constraints
    if table_exists?(:phones) && table_exists?(:contact_phones)
      # First drop dependent tables that reference phones
      drop_table :office_phones if table_exists?(:office_phones)
      # Then drop phones
      execute "DROP TABLE IF EXISTS phones CASCADE"
    end
    
    if table_exists?(:emails) && table_exists?(:contact_emails)
      execute "DROP TABLE IF EXISTS emails CASCADE"
    end
    
    if table_exists?(:bank_accounts) && table_exists?(:contact_bank_accounts)
      execute "DROP TABLE IF EXISTS bank_accounts CASCADE"
    end
    
    # Keep addresses table for now as it's used by Work model
    
    puts "Dropped all legacy contact tables"
  end

  def down
    # This is intentionally left empty since we don't want to recreate legacy tables
    # If rollback is needed, restore from backup
    raise ActiveRecord::IrreversibleMigration
  end
end
