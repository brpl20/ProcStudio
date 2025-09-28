[back](../README.md)

# Deletion System Documentation

## Overview

The ProcStudio API implements a comprehensive deletion system using the `acts_as_paranoid` gem, providing both soft delete (trash bin) and hard delete (permanent removal) capabilities across multiple models.

## How It Works

### Soft Delete (Default)
- **Mechanism**: Sets a `deleted_at` timestamp on the record
- **Record Status**: Remains in database but excluded from normal queries
- **Reversible**: Yes, can be restored
- **Cascade**: Soft deletes dependent associations (if they also use `acts_as_paranoid`)

### Hard Delete
- **Mechanism**: Permanently removes record from database
- **Record Status**: Completely removed, cannot be recovered
- **Reversible**: No
- **Cascade**: Permanently deletes all dependent associations

## Implementation Details

### Key Components

1. **acts_as_paranoid gem**: Provides soft delete functionality
2. **deleted_at column**: Timestamp field tracking when record was soft deleted
3. **DeletedFilterConcern**: Module for filtering deleted records
4. **destroy_fully parameter**: Query parameter to trigger hard delete

### Query Scopes

```ruby
# Default scope (excludes soft-deleted)
Model.all  # WHERE deleted_at IS NULL

# Include soft-deleted records
Model.with_deleted  # No deleted_at filter

# Only soft-deleted records
Model.only_deleted  # WHERE deleted_at IS NOT NULL
```

## API Endpoints by Model

### 1. Customers
```
DELETE /api/v1/customers/:id                    # Soft delete
DELETE /api/v1/customers/:id?destroy_fully=true # Hard delete
POST   /api/v1/customers/:id/restore           # Restore
```

### 2. ProfileCustomers
```
DELETE /api/v1/profile_customers/:id                    # Soft delete
DELETE /api/v1/profile_customers/:id?destroy_fully=true # Hard delete
POST   /api/v1/profile_customers/:id/restore           # Restore
```

### 3. Users
```
DELETE /api/v1/users/:id                    # Soft delete
DELETE /api/v1/users/:id?destroy_fully=true # Hard delete
POST   /api/v1/users/:id/restore           # Restore
```

### 4. UserProfiles
```
DELETE /api/v1/user_profiles/:id                    # Soft delete
DELETE /api/v1/user_profiles/:id?destroy_fully=true # Hard delete
POST   /api/v1/user_profiles/:id/restore           # Restore
```

### 5. Jobs
```
DELETE /api/v1/jobs/:id                    # Soft delete
DELETE /api/v1/jobs/:id?destroy_fully=true # Hard delete
POST   /api/v1/jobs/:id/restore           # Restore
```

### 6. Works
```
DELETE /api/v1/works/:id                    # Soft delete
DELETE /api/v1/works/:id?destroy_fully=true # Hard delete
POST   /api/v1/works/:id/restore           # Restore
```

### 7. WorkEvents
```
DELETE /api/v1/work_events/:id                    # Soft delete
DELETE /api/v1/work_events/:id?destroy_fully=true # Hard delete
POST   /api/v1/work_events/:id/restore           # Restore
```

### 8. Offices
```
DELETE /api/v1/offices/:id                    # Soft delete
DELETE /api/v1/offices/:id?destroy_fully=true # Hard delete
POST   /api/v1/offices/:id/restore           # Restore
```

### 9. Draft Works
```
DELETE /api/v1/draft/works/:id                    # Soft delete
DELETE /api/v1/draft/works/:id?destroy_fully=true # Hard delete
POST   /api/v1/draft/works/:id/restore           # Restore
```

## Request Examples

### Soft Delete (Default)
```bash
curl -X DELETE "http://localhost:3000/api/v1/profile_customers/123" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Hard Delete
```bash
curl -X DELETE "http://localhost:3000/api/v1/profile_customers/123?destroy_fully=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Restore
```bash
curl -X POST "http://localhost:3000/api/v1/profile_customers/123/restore" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Cascade Deletion Behavior

### ProfileCustomer Deletion Effects

When a ProfileCustomer is deleted:

| Associated Model | Soft Delete | Hard Delete |
|-----------------|-------------|-------------|
| Jobs | Soft deleted (has acts_as_paranoid) | Permanently deleted |
| CustomerWorks | Soft deleted (has acts_as_paranoid) | Permanently deleted |
| Works | Not affected (through association) | Not affected (only join deleted) |
| Documents | Soft deleted (if has acts_as_paranoid) | Permanently deleted |
| Addresses | Depends on model configuration | Permanently deleted |
| Phones | Depends on model configuration | Permanently deleted |
| CustomerEmails | Depends on model configuration | Permanently deleted |
| BankAccounts | Through CustomerBankAccounts | Through CustomerBankAccounts |

### Customer Deletion Effects

When a Customer is deleted:

| Associated Model | Soft Delete | Hard Delete |
|-----------------|-------------|-------------|
| ProfileCustomer | Soft deleted | Permanently deleted |
| TeamCustomers | Soft deleted | Permanently deleted |

## Trash Bin Cleanup Strategy (Future Implementation)

### Automated Cleanup Job

Create a background job to automatically clean up old soft-deleted records after a retention period.

#### 1. Create Cleanup Job
```ruby
# app/jobs/trash_cleanup_job.rb
class TrashCleanupJob < ApplicationJob
  queue_as :low

  RETENTION_DAYS = 30

  def perform
    cleanup_date = RETENTION_DAYS.days.ago

    # Models with soft delete capability
    models_to_clean = [
      Customer,
      ProfileCustomer,
      User,
      UserProfile,
      Job,
      Work,
      WorkEvent,
      Office,
      Draft::Work
    ]

    models_to_clean.each do |model|
      cleanup_model(model, cleanup_date)
    end

    log_cleanup_summary
  end

  private

  def cleanup_model(model, cleanup_date)
    deleted_records = model.only_deleted.where('deleted_at < ?', cleanup_date)
    count = deleted_records.count

    if count > 0
      Rails.logger.info "Cleaning up #{count} #{model.name} records deleted before #{cleanup_date}"

      # Batch deletion to avoid memory issues
      deleted_records.find_in_batches(batch_size: 100) do |batch|
        batch.each(&:destroy_fully!)
      end

      # Track in audit log
      AuditLog.create!(
        action: 'trash_cleanup',
        model_name: model.name,
        records_count: count,
        cleanup_date: cleanup_date,
        performed_at: Time.current
      )
    end
  end

  def log_cleanup_summary
    Rails.logger.info "Trash cleanup completed at #{Time.current}"
  end
end
```

#### 2. Schedule with Sidekiq-Cron
```ruby
# config/schedule.yml
trash_cleanup:
  cron: "0 2 * * *"  # Run daily at 2 AM
  class: "TrashCleanupJob"
  queue: low
  description: "Clean up soft-deleted records older than 30 days"
```

#### 3. Manual Cleanup Rake Task
```ruby
# lib/tasks/trash_cleanup.rake
namespace :trash do
  desc "Clean up soft-deleted records older than specified days"
  task :cleanup, [:days] => :environment do |t, args|
    days = (args[:days] || 30).to_i
    puts "Cleaning up records soft-deleted more than #{days} days ago..."

    TrashCleanupJob.new.perform_with_retention(days)

    puts "Cleanup completed!"
  end

  desc "Show statistics of soft-deleted records"
  task stats: :environment do
    puts "\n=== Soft-Deleted Records Statistics ==="
    puts "Model | Total Deleted | Older than 30 days"
    puts "-" * 50

    [Customer, ProfileCustomer, User, UserProfile, Job, Work].each do |model|
      total = model.only_deleted.count
      old = model.only_deleted.where('deleted_at < ?', 30.days.ago).count
      puts "#{model.name.ljust(20)} | #{total.to_s.center(13)} | #{old.to_s.center(18)}"
    end
  end
end
```

#### 4. Configuration Options
```ruby
# config/application.rb
module ProcstudioApi
  class Application < Rails::Application
    # Trash bin retention settings
    config.trash_retention_days = ENV.fetch('TRASH_RETENTION_DAYS', 30).to_i
    config.trash_cleanup_enabled = ENV.fetch('TRASH_CLEANUP_ENABLED', 'true') == 'true'
    config.trash_cleanup_batch_size = ENV.fetch('TRASH_CLEANUP_BATCH_SIZE', 100).to_i
  end
end
```

### User-Facing Trash Bin Features

#### 1. Trash Bin Endpoint
```ruby
# GET /api/v1/trash
# Returns all soft-deleted records accessible by current user
class Api::V1::TrashController < BackofficeController
  def index
    trash_items = gather_trash_items
    render json: {
      success: true,
      data: trash_items,
      meta: {
        total_count: trash_items.sum { |item| item[:count] },
        retention_days: Rails.configuration.trash_retention_days
      }
    }
  end

  private

  def gather_trash_items
    [
      { type: 'customers', items: current_team.customers.only_deleted },
      { type: 'jobs', items: current_team.jobs.only_deleted },
      { type: 'works', items: current_team.works.only_deleted }
    ].map do |trash_type|
      {
        type: trash_type[:type],
        count: trash_type[:items].count,
        items: serialize_trash_items(trash_type[:items].limit(10))
      }
    end
  end
end
```

#### 2. Bulk Restore
```ruby
# POST /api/v1/trash/bulk_restore
def bulk_restore
  model_class = params[:model_type].classify.constantize
  ids = params[:ids]

  restored = model_class.only_deleted.where(id: ids).map(&:recover)

  render json: {
    success: true,
    message: "#{restored.count} items restored",
    restored_ids: restored.map(&:id)
  }
end
```

#### 3. Empty Trash (Permanent Delete)
```ruby
# DELETE /api/v1/trash/empty
def empty
  authorize :trash, :empty?

  if params[:confirm] == 'DELETE_PERMANENTLY'
    count = empty_user_trash
    render json: {
      success: true,
      message: "Permanently deleted #{count} items"
    }
  else
    render json: {
      success: false,
      message: "Confirmation required. Send confirm=DELETE_PERMANENTLY"
    }
  end
end
```

## Best Practices

### 1. Authorization
- Always check permissions before soft/hard delete
- Separate permissions for restore operations
- Super admin override for critical recovery

### 2. Audit Trail
- Log all deletion operations
- Track who deleted what and when
- Store metadata before hard deletion

### 3. User Communication
- Clear messaging about soft vs hard delete
- Warnings before permanent deletion
- Display retention period in UI

### 4. Performance Considerations
- Index `deleted_at` column for all soft-delete tables
- Use batch operations for bulk cleanup
- Consider archiving instead of deletion for compliance

### 5. Testing
```ruby
# RSpec example for deletion testing
RSpec.describe "Deletion System" do
  let(:profile_customer) { create(:profile_customer) }

  describe "soft delete" do
    it "marks record as deleted" do
      profile_customer.destroy
      expect(profile_customer.deleted_at).not_to be_nil
      expect(ProfileCustomer.only_deleted).to include(profile_customer)
    end
  end

  describe "hard delete" do
    it "permanently removes record" do
      id = profile_customer.id
      profile_customer.destroy_fully!
      expect(ProfileCustomer.with_deleted.find_by(id: id)).to be_nil
    end
  end

  describe "restore" do
    it "recovers soft-deleted record" do
      profile_customer.destroy
      profile_customer.recover
      expect(profile_customer.deleted_at).to be_nil
      expect(ProfileCustomer.all).to include(profile_customer)
    end
  end
end
```

## Migration Template

For adding soft delete to new models:

```ruby
class AddSoftDeleteToModel < ActiveRecord::Migration[7.0]
  def change
    add_column :models, :deleted_at, :datetime
    add_index :models, :deleted_at
  end
end
```

## Troubleshooting

### Common Issues

1. **Record not found after soft delete**
   - Use `.with_deleted` or `.only_deleted` scopes
   - Check if model has `acts_as_paranoid`

2. **Cascade deletion not working**
   - Verify dependent models have `acts_as_paranoid`
   - Check `dependent:` option in associations

3. **Cannot restore record**
   - Verify record exists with `.only_deleted.find(id)`
   - Check for validation errors on restore
   - Ensure associated records are restorable

4. **Performance issues with large datasets**
   - Ensure `deleted_at` is indexed
   - Use batch operations for bulk actions
   - Consider partitioning for very large tables

## Security Considerations

1. **Data Recovery**: Soft-deleted data can be recovered - ensure sensitive data is properly handled
2. **Compliance**: Some regulations may require true deletion - use hard delete for GDPR compliance
3. **Access Control**: Implement strict permissions for restore and hard delete operations
4. **Audit Requirements**: Maintain logs of all deletion activities for compliance

## Known Issues and Future Improvements

### User Model Soft Delete Issue (app/models/user.rb:64-70)

**Current Problem:**
The `update_created_by_records` callback nullifies `created_by_id` references when a user is soft deleted. This is problematic because:
1. **Data Loss**: Permanently removes historical audit information about who created records
2. **Inconsistent with Soft Delete**: The user record still exists (just marked with `deleted_at`), so nullifying references defeats the purpose of soft deletion
3. **Foreign Key Constraint Workaround**: This appears to be a workaround for foreign key constraint violations when soft deleting users

**Root Cause:**
The database has foreign key constraints on `created_by_id` columns that reference the users table:
- `customers.created_by_id → users.id`
- `jobs.created_by_id → users.id`
- `profile_customers.created_by_id → users.id`
- `works.created_by_id → users.id`
- `offices.created_by_id → users.id`

These constraints prevent soft deletion because they still validate referential integrity even when using `acts_as_paranoid`.

**Recommended Solution:**
Remove the foreign key constraints and rely on application-level validations instead:

```ruby
# Migration to fix the issue
class RemoveCreatedByForeignKeys < ActiveRecord::Migration[7.1]
  def change
    # Remove foreign key constraints
    remove_foreign_key :customers, column: :created_by_id
    remove_foreign_key :jobs, column: :created_by_id
    remove_foreign_key :profile_customers, column: :created_by_id
    remove_foreign_key :works, column: :created_by_id
    remove_foreign_key :offices, column: :created_by_id
    
    # Keep the indexes for performance
    add_index :customers, :created_by_id unless index_exists?(:customers, :created_by_id)
    add_index :jobs, :created_by_id unless index_exists?(:jobs, :created_by_id)
    add_index :profile_customers, :created_by_id unless index_exists?(:profile_customers, :created_by_id)
    add_index :works, :created_by_id unless index_exists?(:works, :created_by_id)
    add_index :offices, :created_by_id unless index_exists?(:offices, :created_by_id)
  end
end
```

After applying this migration, remove the `before_destroy :update_created_by_records` callback and the associated method from the User model.

**Alternative Solutions (Not Recommended):**
1. **ON DELETE SET NULL**: Modify foreign keys to automatically set NULL on delete, but this still loses audit data
2. **Dependent Nullify**: Add associations with `dependent: :nullify`, but again loses historical information

**Implementation Status:** 
- TODO added to app/models/user.rb:65
- Rubocop disabled for the problematic method (line 64)
- To be addressed in future refactoring
