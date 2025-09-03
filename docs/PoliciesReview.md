[Back](../README.md)

# ProcStudio API - Authorization Policies Documentation

## Overview

The ProcStudio API implements a comprehensive authorization system using **Pundit** for role-based access control (RBAC). The system enforces granular permissions across different user roles and provides multi-tenancy isolation through team scoping. This document provides a detailed analysis of the authorization policies, their implementation, and security considerations.

## Technology Stack

- **Pundit** - Authorization gem for Rails
- **Role-based Access Control (RBAC)** - Permission system based on user roles
- **Team Scoping** - Multi-tenant isolation
- **Paranoia** - Soft deletion support

## Architecture Overview

### 1. User Roles Hierarchy

The system defines a clear role hierarchy with specific permissions:

#### Administrative Roles
- **super_admin** - System-wide administrative access
- **lawyer** - Primary administrative role with most permissions
- **paralegal** - Legal assistant with moderate permissions
- **secretary** - Administrative support with limited permissions

#### Operational Roles  
- **trainee** - Junior legal role with restricted permissions
- **counter** - Accounting/financial role
- **excounter** - Former accounting role (legacy)
- **representant** - Special purpose role for client representation

### 2. Policy Structure

```
ApplicationPolicy (Base)
├── Admin::BasePolicy (Admin namespace)
│   ├── Admin::OfficePolicy
│   ├── Admin::UserPolicy  
│   ├── Admin::CustomerPolicy
│   ├── Admin::WorkPolicy
│   ├── Admin::JobPolicy
│   ├── Admin::PowerPolicy
│   └── Admin::LawAreaPolicy
├── Customer::CustomerPolicy (Customer namespace)
│   ├── Customer::ProfileCustomerPolicy
│   └── Customer::WorkPolicy
└── RepresentPolicy (Special cases)
```

## Role-Based Permission Matrix

### Office Management (`Admin::OfficePolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| show   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| create | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| update | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| restore| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| destroy| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

### User Management (`Admin::UserPolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| show   | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| create | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| update | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| destroy| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| restore| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

### Customer Management (`Admin::CustomerPolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| show   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| create | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| update | ✅ | ✅ | ✅ | ✅* | ✅* | ❌ | ❌ |
| destroy| ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| restore| ✅ | ✅ | ✅ | ✅* | ✅* | ❌ | ❌ |
| resend_confirmation | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |

*\*Only if they are the record owner*

### Work Management (`Admin::WorkPolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| show   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| create | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| update | ✅ | ✅ | ✅ | ✅* | ✅* | ✅ | ❌ |
| destroy| ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| restore| ✅ | ✅ | ✅ | ✅* | ✅* | ✅ | ❌ |
| convert_documents_to_pdf | ✅ | ✅ | ✅ | ✅* | ✅* | ✅ | ❌ |

*\*Only if they are the record owner*

### Job Management (`Admin::JobPolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| show   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| create | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| update | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| destroy| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| restore| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

### Power Management (`Admin::PowerPolicy`)

| Action | super_admin | lawyer | paralegal | trainee | secretary | counter | excounter |
|--------|-------------|--------|-----------|---------|-----------|---------|-----------|
| index  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| show   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| create | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| update | ✅ | ✅** | ❌ | ❌ | ❌ | ❌ | ❌ |
| destroy| ✅ | ✅** | ❌ | ❌ | ❌ | ❌ | ❌ |

*\*\*Only for custom powers within their team (lawyers cannot modify system powers)*

## Detailed Policy Analysis

### 1. Admin::BasePolicy

The foundational policy class that provides:

```ruby
class Admin::BasePolicy < ApplicationPolicy
  def role
    @role ||= user&.user_profile&.role
  end

  def owner?
    record.created_by_id == user.id
  end

  # Dynamic role methods (lawyer?, paralegal?, etc.)
  UserProfile.roles.each_key do |role|
    define_method("#{role}?") do
      self.role == role
    end
  end
end
```

**Key Features:**
- **Role Detection** - Automatically determines user role from profile
- **Ownership Check** - Provides `owner?` method for record ownership validation
- **Dynamic Role Methods** - Generates role checking methods (`lawyer?`, `paralegal?`, etc.)

### 2. Customer Self-Service Policies

#### Customer::CustomerPolicy
```ruby
class Customer::CustomerPolicy < ApplicationPolicy
  def show?
    user.confirmed? && user == record
  end

  def update?
    show?
  end
end
```

**Security Features:**
- **Email Confirmation Required** - Users must confirm email before access
- **Self-Access Only** - Customers can only access their own records

#### Customer::ProfileCustomerPolicy
```ruby
class Customer::ProfileCustomerPolicy < ApplicationPolicy
  def show?
    user.confirmed? && user == record.customer
  end

  def update?
    show?
  end
end
```

### 3. Team Scoping and Multi-Tenancy

The `RepresentPolicy` demonstrates advanced team scoping:

```ruby
class RepresentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.by_team(user.current_team_id)
    end
  end

  private

  def record_in_team?
    record.team_id == user.current_team_id
  end
end
```

**Multi-Tenancy Features:**
- **Automatic Team Filtering** - Scopes records to user's current team
- **Cross-Team Prevention** - Prevents access to other teams' data
- **Team Validation** - Ensures all operations stay within team boundaries

## Security Considerations

### 1. Ownership-Based Permissions

Several policies implement ownership-based access control:

```ruby
# Trainees and secretaries can only update records they created
def update?
  lawyer? || paralegal? || counter? || (trainee? && owner?) || (secretary? && owner?)
end
```

**Benefits:**
- **Data Isolation** - Users can only modify their own created records
- **Responsibility Tracking** - Clear accountability for data changes
- **Graduated Permissions** - Junior roles have limited but useful access

### 2. Role Hierarchy Enforcement

The system enforces a clear hierarchy:

1. **super_admin** - Unrestricted access to all resources
2. **lawyer** - Primary administrative access (can manage most resources)
3. **paralegal** - Moderate access (can manage customers and works)
4. **secretary** - Limited administrative access
5. **trainee** - Restricted access with ownership requirements
6. **counter/excounter** - Specialized financial access

### 3. Special Permission Logic

#### Power Management
```ruby
def update?
  return true if super_admin?
  return false unless lawyer?

  # Custom powers can be edited by team lawyers
  if record.custom_power?
    record.created_by_team == user.team
  else
    # System powers only editable by super_admin
    false
  end
end
```

**Advanced Features:**
- **System vs Custom Resources** - Different rules for system and user-generated content
- **Team-Based Ownership** - Custom resources scoped to creating team
- **Hierarchical Override** - Super admins can override team restrictions

### 4. Action-Specific Permissions

Different actions have different permission requirements:

- **Read Operations** (index/show) - Generally permissive
- **Create Operations** - More restrictive, usually require mid-level+ roles
- **Update Operations** - Often include ownership checks for junior roles  
- **Delete Operations** - Most restrictive, usually senior roles only
- **Restore Operations** - Similar to update permissions

## Controller Integration

### Authorization Flow

```ruby
class OfficesController < BackofficeController
  before_action :retrieve_office, only: [:show, :update]
  before_action :perform_authorization, except: [:with_lawyers]
  after_action :verify_authorized

  def index
    authorize Office
    # ...
  end

  def show
    authorize @office
    # ...
  end
end
```

**Key Components:**
- **before_action :perform_authorization** - Ensures authorization happens
- **after_action :verify_authorized** - Verifies authorization was called
- **authorize** calls - Explicit authorization checks

### Team Scoping Integration

```ruby
def index
  @offices = OfficeFilter.retrieve_offices(current_team)
  # Automatically scoped to user's team
end

def create
  @office = current_team.offices.build(offices_params)
  # New records automatically belong to user's team
end
```

## Error Handling

### Authorization Failures

When authorization fails, Pundit raises exceptions that are handled by the application:

- **Pundit::NotAuthorizedError** - User lacks permission for action
- **Pundit::AuthorizationNotPerformedError** - Developer error, no authorization check
- **Pundit::PolicyScopingNotPerformedError** - Missing scope authorization

### Standard Error Responses

```json
{
  "success": false,
  "message": "Usuário não autorizado",
  "errors": ["Usuário não autorizado"]
}
```

## Testing Authorization

### RSpec Policy Testing

```ruby
RSpec.describe Admin::OfficePolicy do
  subject { described_class }

  let(:lawyer) { create(:user, :lawyer) }
  let(:trainee) { create(:user, :trainee) }
  let(:office) { create(:office) }

  permissions :create? do
    it "allows lawyers to create offices" do
      expect(subject).to permit(lawyer, Office)
    end

    it "denies trainees from creating offices" do  
      expect(subject).not_to permit(trainee, Office)
    end
  end
end
```

### Policy Testing Coverage

The system should include comprehensive tests for:
- **Role-based permissions** - Each role's access to each action
- **Ownership scenarios** - Owner vs non-owner access patterns
- **Team scoping** - Cross-team access prevention
- **Edge cases** - Deleted records, special conditions

## Database Schema Integration

### User Profiles and Roles

```sql
-- user_profiles table stores role information
CREATE TABLE user_profiles (
  id bigint PRIMARY KEY,
  user_id bigint NOT NULL,
  role string, -- lawyer, paralegal, trainee, etc.
  office_id bigint,
  -- ... other profile fields
);
```

### Team Association

```sql  
-- users belong to teams for multi-tenancy
CREATE TABLE users (
  id bigint PRIMARY KEY,
  team_id bigint NOT NULL,
  -- ... authentication fields
);
```

### Audit Trail Support

```sql
-- Most models include created_by for ownership tracking
created_by_id bigint, -- References users.id
team_id bigint,       -- For team scoping
deleted_at datetime,  -- Soft deletion support
```

## Best Practices Implemented

### 1. Defense in Depth
- **Multiple Authorization Layers** - Controller, model, and view-level checks
- **Automatic Team Scoping** - Prevents accidental cross-team access  
- **Ownership Validation** - Additional protection for sensitive operations

### 2. Principle of Least Privilege
- **Role-Based Restrictions** - Users only get permissions they need
- **Action-Specific Rules** - Different permissions for different operations
- **Graduated Access** - Junior roles have limited but functional access

### 3. Maintainable Authorization
- **Centralized Policy Logic** - All authorization rules in policy classes
- **Consistent Patterns** - Similar roles have similar permissions across resources
- **Clear Role Hierarchy** - Well-defined progression of permissions

## Security Vulnerabilities and Mitigations

### 1. Mass Assignment Protection
```ruby
# Strong parameters prevent unauthorized field updates
def offices_params
  params.require(:office).permit(:name, :cnpj, ...)
end
```

### 2. Team Isolation
```ruby
# All queries automatically scoped to user's team
@offices = current_team.offices.all
```

### 3. Ownership Verification
```ruby
# Policies check record ownership for sensitive operations
def update?
  lawyer? || (trainee? && owner?)
end
```

## Future Enhancements

### 1. Planned Improvements
- **Permission Caching** - Cache role checks to improve performance
- **Audit Logging** - Track all authorization decisions for compliance
- **Dynamic Permissions** - Allow runtime permission configuration
- **Resource-Level Permissions** - Granular permissions on individual records

### 2. Advanced Features
- **Time-Based Permissions** - Permissions that expire or activate
- **Context-Aware Authorization** - Permissions based on request context
- **Delegation Support** - Temporary permission delegation between users
- **API Rate Limiting** - Role-based API usage limits

## Troubleshooting

### Common Issues

1. **"Usuário não autorizado"**
   - Check user role assignment in user_profile
   - Verify policy method exists for the action
   - Confirm record ownership if required

2. **Missing Authorization**  
   - Ensure `authorize` is called in controller actions
   - Check `after_action :verify_authorized` is present
   - Verify policy class exists and follows naming convention

3. **Cross-Team Access Errors**
   - Confirm team scoping is properly implemented
   - Check current_team context is set correctly
   - Verify team associations are properly configured

4. **Role Method Errors**
   - Ensure user has a user_profile with valid role
   - Check UserProfile.roles enum includes all required roles
   - Verify role assignment matches enum values

## API Client Authorization Example

### JavaScript/Axios
```javascript
// Authorization errors are returned as 401/403 responses
try {
  const response = await axios.post('/api/v1/offices', officeData, {
    headers: { Authorization: `Bearer ${token}` }
  });
} catch (error) {
  if (error.response?.status === 401) {
    // Handle authorization failure
    redirectToLogin();
  } else if (error.response?.status === 403) {
    // Handle insufficient permissions
    showPermissionError();
  }
}
```

## Support and Contact

For authorization issues:
- **Check application logs** for detailed policy failure reasons
- **Review user roles** in user_profile table  
- **Verify team associations** for multi-tenancy issues
- **Test policies in Rails console** for debugging

---

## Summary

The ProcStudio API authorization system provides:

- **Comprehensive Role-Based Access Control** with 8 distinct user roles
- **Multi-Tenant Security** with automatic team scoping  
- **Granular Permissions** covering all major operations
- **Ownership-Based Access** for enhanced data protection
- **Scalable Architecture** supporting future enhancements

The system successfully balances security with usability, providing appropriate access levels for different user types while maintaining strict data isolation and audit capabilities.