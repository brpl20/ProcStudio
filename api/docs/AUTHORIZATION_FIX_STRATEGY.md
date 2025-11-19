# Authorization Fix Strategy

**Branch**: `authorization_fix`
**Date**: November 19, 2024
**Status**: In Progress

## Overview

This document outlines the strategy for completing the authorization system fixes across the ProcStudio API. The attachment transfer system has been implemented, but further authorization refinements are needed.

## Current State

### ✅ Completed Tasks

1. **Attachment Transfer System Implemented**
   - Created `AttachmentTransferService` for moving files between models
   - Added `AttachmentTransferable` concern to controllers
   - Added transfer endpoints to all models (Office, UserProfile, Work, Job, ProfileCustomer)
   - Migration added for transfer tracking fields

2. **Authorization Fixed in Controllers**
   - `OfficesController`: Fixed to use `Admin::OfficePolicy`
   - `UserProfilesController`: Fixed to use `[:admin, :user]` pattern
   - `ProfileCustomersController`: Fixed to use `Admin::CustomerPolicy`
   - `WorksController`: Fixed to use `Admin::WorkPolicy`
   - `JobsController`: Fixed to use `Admin::JobPolicy` (was incorrectly using `Admin::WorkPolicy`)

3. **Policy Methods Added**
   - All Admin policies now have: `upload_attachment?`, `remove_attachment?`, `transfer_attachment?`
   - Additional methods added: `upload_logo?`, `upload_contracts?`, `upload_avatar?`

### 📋 Authorization Pattern Reference

The application uses a consistent authorization pattern:

```ruby
# For actions without a specific model instance
authorize [:admin, :model], :action_name?

# For actions with a model instance
authorize @model, :action?, policy_class: Admin::ModelPolicy

# Examples:
authorize [:admin, :office], :index?          # Uses Admin::OfficePolicy
authorize @office, :update?, policy_class: Admin::OfficePolicy
```

### 🗂️ Policy Structure

```
app/policies/
├── admin/
│   ├── base_policy.rb          # Base for all Admin policies
│   ├── office_policy.rb        # Office authorization
│   ├── customer_policy.rb      # ProfileCustomer authorization
│   ├── work_policy.rb          # Work authorization
│   ├── job_policy.rb           # Job authorization
│   ├── user_policy.rb          # UserProfile authorization (via User)
│   └── ...
├── user_profile_policy.rb      # NOT in Admin namespace
├── notification_policy.rb      # NOT in Admin namespace
└── application_policy.rb       # Base policy
```

## Pending Tasks

### 1. Review and Test All Authorization Endpoints

**Priority**: HIGH

Test each endpoint to ensure:
- Proper authorization is enforced
- Correct policy class is used
- All roles have appropriate access

**Endpoints to Test**:
```
# Offices
POST   /api/v1/offices/:id/upload_logo
POST   /api/v1/offices/:id/upload_contracts
POST   /api/v1/offices/:id/upload_attachment
DELETE /api/v1/offices/:id/attachments/:attachment_id
POST   /api/v1/offices/:id/attachments/:attachment_id/transfer

# UserProfiles
POST   /api/v1/user_profiles/:id/upload_avatar
POST   /api/v1/user_profiles/:id/upload_attachment
DELETE /api/v1/user_profiles/:id/attachments/:attachment_id
POST   /api/v1/user_profiles/:id/attachments/:attachment_id/transfer

# ProfileCustomers
POST   /api/v1/profile_customers/:id/upload_attachment
DELETE /api/v1/profile_customers/:id/attachments/:attachment_id
POST   /api/v1/profile_customers/:id/attachments/:attachment_id/transfer

# Works
POST   /api/v1/works/:id/upload_attachment
DELETE /api/v1/works/:id/attachments/:attachment_id
POST   /api/v1/works/:id/attachments/:attachment_id/transfer

# Jobs
POST   /api/v1/jobs/:id/upload_attachment
DELETE /api/v1/jobs/:id/attachments/:attachment_id
POST   /api/v1/jobs/:id/attachments/:attachment_id/transfer

# Global
POST   /api/v1/attachments/:id/transfer
```

### 2. Add Authorization Tests

**Priority**: HIGH

Create RSpec request specs for authorization:

```ruby
# spec/requests/api/v1/offices/authorization_spec.rb
RSpec.describe 'Office Authorization', type: :request do
  describe 'POST /api/v1/offices/:id/upload_attachment' do
    context 'as lawyer' do
      it 'allows upload' do
        # Test implementation
      end
    end

    context 'as secretary' do
      it 'allows upload' do
        # Test implementation
      end
    end

    context 'as trainee' do
      it 'denies upload' do
        # Test implementation
      end
    end
  end
end
```

**Files to Create**:
- `spec/requests/api/v1/offices/authorization_spec.rb`
- `spec/requests/api/v1/user_profiles/authorization_spec.rb`
- `spec/requests/api/v1/profile_customers/authorization_spec.rb`
- `spec/requests/api/v1/works/authorization_spec.rb`
- `spec/requests/api/v1/jobs/authorization_spec.rb`

### 3. Audit Other Controllers for Missing Authorization

**Priority**: MEDIUM

Check all controllers in `app/controllers/api/v1/` for:
- Missing `before_action :perform_authorization`
- Missing `after_action :verify_authorized`
- Inconsistent authorization patterns

**Controllers to Audit**:
```bash
grep -L "perform_authorization\|verify_authorized" app/controllers/api/v1/*.rb
```

### 4. Standardize Authorization Across All Models

**Priority**: MEDIUM

Ensure all models with attachments have consistent authorization:

**Required Methods in Each Policy**:
- `upload_attachment?`
- `remove_attachment?`
- `transfer_attachment?`

**Special Methods** (model-specific):
- Office: `upload_logo?`, `upload_contracts?`
- UserProfile: `upload_avatar?`
- Work: `upload_document?` (if different from upload_attachment)

### 5. Document Authorization Roles and Permissions

**Priority**: LOW

Create a comprehensive authorization matrix:

| Action | Lawyer | Paralegal | Trainee | Secretary | Counter |
|--------|--------|-----------|---------|-----------|---------|
| Office: upload_logo | ✅ | ❌ | ❌ | ❌ | ❌ |
| Office: upload_attachment | ✅ | ❌ | ❌ | ✅ | ❌ |
| Office: transfer_attachment | ✅ | ❌ | ❌ | ❌ | ❌ |
| ... | ... | ... | ... | ... | ... |

### 6. Fix Authorization in Attachment Services

**Priority**: LOW

Review and update authorization in service objects:
- `Offices::LogoUploadService`
- `Offices::ContractsUploadService`
- `Offices::AttachmentRemovalService`

Ensure they don't duplicate authorization that's already in controllers.

## Common Issues and Solutions

### Issue 1: "undefined method `action_name?` for Policy"

**Cause**: Missing authorization method in policy class.

**Solution**: Add the missing method to the appropriate policy:
```ruby
def upload_attachment?
  lawyer? || secretary?
end
```

### Issue 2: "uninitialized constant PolicyName"

**Cause**: Policy class doesn't exist or wrong namespace.

**Solution**:
1. Check if policy exists in `app/policies/`
2. Verify namespace (Admin:: or not)
3. Use correct policy_class in authorize call

### Issue 3: Wrong Policy Being Used

**Cause**: Incorrect `perform_authorization` pattern.

**Solution**: Update to correct pattern:
```ruby
# Correct patterns:
authorize [:admin, :office], :"#{action_name}?"  # For Office model
authorize [:admin, :user], :"#{action_name}?"    # For UserProfile model
authorize [:admin, :work], :"#{action_name}?"    # For Work model
```

## Testing Strategy

### Manual Testing Checklist

For each endpoint, test with different user roles:

```bash
# 1. Create test users with different roles
rails runner "
  team = Team.first

  # Lawyer
  lawyer = User.create!(email: 'lawyer@test.com', password: '123456', team: team)
  lawyer.create_user_profile!(name: 'Lawyer', role: 'lawyer')

  # Secretary
  secretary = User.create!(email: 'secretary@test.com', password: '123456', team: team)
  secretary.create_user_profile!(name: 'Secretary', role: 'secretary')

  # Trainee
  trainee = User.create!(email: 'trainee@test.com', password: '123456', team: team)
  trainee.create_user_profile!(name: 'Trainee', role: 'trainee')
"

# 2. Test each endpoint with curl or Postman
# Example:
curl -X POST http://localhost:3000/api/v1/offices/1/upload_attachment \
  -H "Authorization: Bearer $LAWYER_TOKEN" \
  -F "attachment=@test.pdf"
```

### Automated Testing

Run RSpec tests after creating authorization specs:

```bash
# Test all authorization specs
rspec spec/requests/api/v1/*/authorization_spec.rb

# Test specific model
rspec spec/requests/api/v1/offices/authorization_spec.rb

# Run with documentation format
rspec spec/requests/api/v1/*/authorization_spec.rb --format documentation
```

## Implementation Steps for Next Agent

### Step 1: Test Current Implementation (30 min)
1. Start Rails server
2. Authenticate as different user roles
3. Test all attachment endpoints
4. Document any authorization errors

### Step 2: Create Authorization Test Suite (2 hours)
1. Create base authorization spec helper
2. Write authorization specs for each model
3. Run tests and fix failures

### Step 3: Audit All Controllers (1 hour)
1. List all controllers without authorization
2. Add missing authorization where needed
3. Verify authorization patterns are consistent

### Step 4: Document Permissions (30 min)
1. Create authorization matrix
2. Update API documentation with role requirements
3. Add comments to policy files

### Step 5: Final Testing and Cleanup (1 hour)
1. Run full test suite
2. Test in development environment
3. Update CHANGELOG
4. Create PR for review

## Files Modified in This Branch

### Controllers
- `app/controllers/api/v1/offices_controller.rb`
- `app/controllers/api/v1/user_profiles_controller.rb`
- `app/controllers/api/v1/profile_customers_controller.rb`
- `app/controllers/api/v1/works_controller.rb`
- `app/controllers/api/v1/jobs_controller.rb`
- `app/controllers/api/v1/attachments_controller.rb` (NEW)
- `app/controllers/concerns/attachment_transferable.rb` (NEW)

### Policies
- `app/policies/admin/office_policy.rb`
- `app/policies/admin/user_policy.rb`
- `app/policies/admin/customer_policy.rb`
- `app/policies/admin/work_policy.rb`
- `app/policies/admin/job_policy.rb`

### Services
- `app/services/attachment_transfer_service.rb` (NEW)
- `app/services/s3_manager.rb`

### Migrations
- `db/migrate/20251119184742_add_transfer_fields_to_file_metadata.rb` (NEW)

### Routes
- `config/routes.rb`

### Documentation
- `docs/S3_FILE_UPLOAD_MANUAL.md`

## References

### Pundit Documentation
- [Pundit Policies](https://github.com/varvet/pundit#policies)
- [Policy Scopes](https://github.com/varvet/pundit#scopes)
- [Testing Policies](https://github.com/varvet/pundit#testing)

### Related Files
- Authorization base: `app/controllers/backoffice_controller.rb`
- Policy base: `app/policies/application_policy.rb`
- Admin policy base: `app/policies/admin/base_policy.rb`

## Notes

- The `UserProfile` model uses `Admin::UserPolicy` (via `[:admin, :user]` pattern)
- `NotificationPolicy` and `UserProfilePolicy` are NOT in Admin namespace
- Transfer operations require lawyer or paralegal role by default
- All attachment operations require proper authorization

## Success Criteria

This authorization fix will be considered complete when:

1. ✅ All attachment endpoints have proper authorization
2. ✅ All tests pass
3. ✅ Authorization is documented
4. ✅ No authorization errors in logs
5. ✅ Manual testing confirms role-based access works correctly

---

**Last Updated**: November 19, 2024
**Next Review**: After completing Step 1 (Testing Current Implementation)
