# Rails Model Restructuring Migration Plan

## Overview
This document outlines the complete migration plan for restructuring the Customer, ProfileCustomer, IndividualEntity, and LegalEntity models to implement a cleaner polymorphic architecture with support for law office functionality.

## Migration Order (CRITICAL - Must be executed in this sequence)

1. **CreateLegalEntityOffices** (20250810213735)
   - Creates `legal_entity_offices` table
   - Stores law firm specific fields (oab_id, inscription_number, society_link, legal_specialty)
   - Links to LegalEntity and Team

2. **CreateLegalEntityOfficeRelationships** (20250810213856)
   - Creates `legal_entity_office_relationships` table
   - Manages lawyer-office relationships
   - Tracks partnership types and ownership percentages

3. **AddPolymorphicAssociationToCustomers** (20250810213921)
   - Adds `profile_type` and `profile_id` columns to `customers` table
   - Creates polymorphic index for efficient queries

4. **MigrateLegalEntityDataToOffice** (20250810213944)
   - Data migration to move law office fields from LegalEntity to LegalEntityOffice
   - Preserves existing data with rollback capability

5. **MigrateCustomerDataToPolymorphic** (20250810214016)
   - Data migration to convert Customer associations from ProfileCustomer to polymorphic
   - Links Customers directly to IndividualEntity or LegalEntity

6. **RemoveDeprecatedFieldsFromLegalEntity** (20250810214052)
   - Removes `oab_id`, `society_link`, and `inscription_number` from `legal_entities` table
   - These fields are now stored in `legal_entity_offices`

## New Model Structure

### LegalEntityOffice
- Stores law office specific information
- One-to-one relationship with LegalEntity
- Has many lawyers through LegalEntityOfficeRelationship

### LegalEntityOfficeRelationship
- Join table between LegalEntityOffice and IndividualEntity (as lawyer)
- Tracks partnership type: socio, associado, socio_de_servico
- Stores ownership percentage for partners

### Updated Customer Model
- Now uses polymorphic association to either IndividualEntity or LegalEntity
- ProfileCustomer remains for backward compatibility but should be deprecated in future

## Key Association Changes

### Customer
```ruby
belongs_to :profile, polymorphic: true, optional: true
# profile can be either IndividualEntity or LegalEntity
```

### LegalEntity
```ruby
has_one :legal_entity_office
has_many :lawyers, through: :legal_entity_office
has_many :customers, as: :profile
```

### IndividualEntity
```ruby
has_many :legal_entity_office_relationships, foreign_key: :lawyer_id
has_many :legal_entity_offices, through: :legal_entity_office_relationships
has_many :customers, as: :profile
```

## Running the Migrations

```bash
# Run all migrations
rails db:migrate

# Verify migration status
rails db:migrate:status

# Test the migrations (optional but recommended)
ruby test_model_restructure_migrations.rb
```

## Rollback Instructions

If you need to rollback these migrations, execute in reverse order:

```bash
rails db:migrate:down VERSION=20250810214052  # RemoveDeprecatedFieldsFromLegalEntity
rails db:migrate:down VERSION=20250810214016  # MigrateCustomerDataToPolymorphic
rails db:migrate:down VERSION=20250810213944  # MigrateLegalEntityDataToOffice
rails db:migrate:down VERSION=20250810213921  # AddPolymorphicAssociationToCustomers
rails db:migrate:down VERSION=20250810213856  # CreateLegalEntityOfficeRelationships
rails db:migrate:down VERSION=20250810213735  # CreateLegalEntityOffices
```

## Post-Migration Tasks

1. **Update Controllers**: Modify controllers to work with the new polymorphic associations
2. **Update Serializers**: Update API serializers to handle the new structure
3. **Update Tests**: Update existing tests to work with new model structure
4. **Deprecate ProfileCustomer**: Plan for complete removal of ProfileCustomer model in future release
5. **Update Seeds**: Update seed files to use the new model structure

## Benefits of New Structure

1. **Cleaner Architecture**: Polymorphic associations eliminate redundant ProfileCustomer intermediary
2. **Extensibility**: Easy to add new entity types in the future
3. **Law Office Support**: Dedicated tables for law office functionality
4. **Better Performance**: Direct associations reduce query complexity
5. **Data Integrity**: Foreign keys and constraints ensure data consistency

## Potential Issues and Solutions

### Issue 1: Existing ProfileCustomer Dependencies
**Solution**: Keep ProfileCustomer temporarily, migrate gradually to polymorphic associations

### Issue 2: Data Migration Failures
**Solution**: All migrations include rollback logic, test in staging first

### Issue 3: API Compatibility
**Solution**: Maintain backward compatibility through serializers during transition period

## Testing Checklist

- [ ] Run migrations on development database
- [ ] Verify all tables created correctly
- [ ] Test data migration preserves existing records
- [ ] Verify model associations work as expected
- [ ] Test rollback capability
- [ ] Run existing test suite
- [ ] Test API endpoints still function
- [ ] Deploy to staging environment
- [ ] Perform full regression testing
- [ ] Deploy to production (with backup)