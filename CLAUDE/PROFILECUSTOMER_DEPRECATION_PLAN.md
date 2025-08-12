# ProfileCustomer Deprecation Plan

## Current Status
The Customer model now uses polymorphic associations directly with IndividualEntity or LegalEntity, making ProfileCustomer redundant. However, ProfileCustomer should be kept temporarily for backward compatibility.

## Why Keep ProfileCustomer for Now?

### 1. **Existing Code Dependencies**
- Controllers may still reference ProfileCustomer
- API endpoints might depend on ProfileCustomer serialization
- Frontend code may expect ProfileCustomer data structure

### 2. **Gradual Migration Safety**
- Some customers might still use the old ProfileCustomer relationship
- Provides fallback mechanism during transition period
- Allows testing of new polymorphic system without breaking existing functionality

### 3. **Data Integrity**
- ProfileCustomer contains important historical data
- Some fields in ProfileCustomer might not be fully migrated yet
- Provides audit trail of data structure evolution

## Deprecation Strategy

### Phase 1: Compatibility Mode (Current)
- ✅ Keep ProfileCustomer model and associations
- ✅ Use polymorphic Customer associations as primary
- ✅ ProfileCustomer serves as backup/fallback
- ✅ Both systems work side by side

### Phase 2: Deprecation Warnings (Future)
```ruby
# Add to ProfileCustomer model
class ProfileCustomer < ApplicationRecord
  def self.deprecated_warning
    Rails.logger.warn "ProfileCustomer is deprecated. Use Customer.profile polymorphic association instead."
  end
  
  after_find :log_deprecation_warning
  
  private
  
  def log_deprecation_warning
    self.class.deprecated_warning
  end
end
```

### Phase 3: Migration Script (Future)
```ruby
# Script to ensure all customers use polymorphic associations
Customer.includes(:profile_customer).where(profile_type: nil).find_each do |customer|
  profile_customer = customer.profile_customer
  next unless profile_customer
  
  if profile_customer.individual_entity_id
    customer.update!(
      profile_type: 'IndividualEntity',
      profile_id: profile_customer.individual_entity_id
    )
  elsif profile_customer.legal_entity_id
    customer.update!(
      profile_type: 'LegalEntity', 
      profile_id: profile_customer.legal_entity_id
    )
  end
end
```

### Phase 4: Final Removal (Future)
- Remove ProfileCustomer model
- Remove profile_customers table
- Clean up remaining references

## Current Implementation Strategy

### For New Development
**Always use the polymorphic associations:**
```ruby
# ✅ Correct - Use polymorphic association
customer = Customer.find(10)
if customer.individual_entity?
  individual = customer.profile  # IndividualEntity
elsif customer.legal_entity?
  company = customer.profile     # LegalEntity
end

# ❌ Avoid - Don't use ProfileCustomer
profile_customer = customer.profile_customer  # Deprecated
```

### For Existing Code
**Gradually migrate to polymorphic:**
```ruby
# Current compatibility approach
def get_customer_entity(customer)
  # Try polymorphic first
  return customer.profile if customer.profile
  
  # Fallback to ProfileCustomer
  profile_customer = customer.profile_customer
  return profile_customer.individual_entity if profile_customer&.individual_entity
  return profile_customer.legal_entity if profile_customer&.legal_entity
  
  nil
end
```

### For APIs
**Support both formats during transition:**
```ruby
# CustomerSerializer - support both old and new formats
class CustomerSerializer
  def profile_data
    # New polymorphic approach (preferred)
    if object.profile
      return serialize_polymorphic_profile
    end
    
    # Legacy ProfileCustomer fallback
    if object.profile_customer
      return serialize_profile_customer
    end
    
    nil
  end
  
  private
  
  def serialize_polymorphic_profile
    case object.profile_type
    when 'IndividualEntity'
      IndividualEntitySerializer.new(object.profile)
    when 'LegalEntity'  
      LegalEntitySerializer.new(object.profile)
    end
  end
  
  def serialize_profile_customer
    # Legacy format for backward compatibility
    ProfileCustomerSerializer.new(object.profile_customer)
  end
end
```

## Migration Checklist

### Before Removing ProfileCustomer:
- [ ] All customers have polymorphic profile associations
- [ ] All API endpoints use new Customer#profile approach
- [ ] Frontend applications updated to use new data structure
- [ ] All controllers migrated from ProfileCustomer to Customer#profile
- [ ] No remaining direct references to ProfileCustomer in business logic
- [ ] Comprehensive testing with new polymorphic approach
- [ ] Data backup created
- [ ] Rollback plan documented

### Red Flags - Don't Remove If:
- Any Customer has `profile_type: nil` and valid ProfileCustomer
- API responses still depend on ProfileCustomer format
- Frontend code expects ProfileCustomer data structure
- Integration tests fail without ProfileCustomer

## Recommendation: Current Approach ✅

**Keep ProfileCustomer for now** because:
1. **Zero Risk**: Both systems work, no breaking changes
2. **Gradual Transition**: Can migrate controllers/APIs one by one
3. **Fallback Safety**: If polymorphic fails, ProfileCustomer provides backup
4. **Data Preservation**: No data loss during architecture evolution

**Use polymorphic associations for all new development** and gradually migrate existing code when convenient.