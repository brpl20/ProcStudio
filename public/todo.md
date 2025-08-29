# TODO List - Next Session

## 🔍 **Check Enums Old Version x Rails 8 Version Across All System**
- ✅ Audit all enum declarations in the codebase - COMPLETED
- ✅ Convert old syntax `enum attribute: {}` to new Rails 8 syntax `enum :attribute, {}` - ALL DONE
- ✅ Fixed UserOffice model enum syntax issue
- ✅ Verified all other models already using correct Rails 8 syntax
- ✅ Test enum functionality after conversions - WORKING

## 🔧 **Fix OfficeSerializer Issues**
- ❌ Remove or fix `office_type_description` attribute (lines 48-50)
- Office model no longer has `office_type` association after migration
- Consider what should replace this attribute or remove it entirely

## 🧪 **Finish New Polymorphic Tests**
- Create comprehensive RSpec tests for polymorphic Address model
- Create comprehensive RSpec tests for polymorphic Phone model
- Test Office polymorphic associations (addresses, phones)
- Test ProfileCustomer polymorphic associations (addresses, phones)
- Test edge cases: validation, uniqueness, soft deletes
- Update existing test factories for new polymorphic structure
- Fix any broken specs due to model changes

## 🔌 **Check if API Methods Need Changes for New Polymorphic Methods**

### **Considerations:**

**Serializers**:
- ✅ `AddressSerializer` and `OfficeSerializer` already updated with new schema
- ❓ Check if `ProfileCustomerSerializer` needs nested address/phone serialization
- ❓ Verify JSON:API relationships are properly configured

**Controllers**:
- ❓ Office controller: May need params updates for nested addresses/phones
- ❓ ProfileCustomer controller: May need params updates for nested addresses/phones
- ❓ Check strong parameters permit nested attributes: `addresses_attributes`, `phones_attributes`

**API Endpoints**:
- ❓ POST/PUT `/offices` - Test nested creation of addresses/phones
- ❓ POST/PUT `/profile_customers` - Test nested creation of addresses/phones
- ❓ Check if existing API clients expect old join table structure
- ❓ Verify backwards compatibility or document breaking changes

**Database Queries**:
- ❓ Check for any raw SQL or ActiveRecord queries that reference old join tables
- ❓ Update scopes that may have used `joins(:customer_addresses)` syntax
- ❓ Verify eager loading: `includes(:addresses)` instead of `includes(:customer_addresses)`

**Frontend/Mobile Compatibility**:
- ❓ Check if mobile app or frontend expects old API response format
- ❓ Update API documentation if response structure changed
- ❓ Consider versioning API if breaking changes are introduced

---
*Created: 2025-08-28 - Great work on polymorphic refactoring! 🚀*


lembrar do active Office para os dados do Contrato Social
Criar contrato social
