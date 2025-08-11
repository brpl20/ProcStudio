# Contact Information Architecture Recommendation

## Current Issues
1. **Dual Systems**: Legacy separate tables + new polymorphic ContactInfo
2. **JSON Limitations**: Harder to query, validate, and index
3. **Inconsistent Data**: Different structures for same contact type
4. **Performance**: JSON queries are slower than structured columns

## Recommended Architecture: Single Polymorphic with STI (Single Table Inheritance)

### Option A: Enhanced ContactInfo with Structured Columns
```ruby
# Enhanced contact_infos table structure
class ContactInfo < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  # Common fields
  # id, contactable_type, contactable_id, type, is_primary, created_at, updated_at
  
  # Contact-specific fields (nullable, used based on type)
  # Addresses
  # street, number, complement, neighborhood, city, state, zip_code, country
  
  # Phones  
  # phone_number, phone_type (mobile, landline, commercial, fax)
  
  # Emails
  # email_address, email_type (personal, work, billing)
  
  # Bank Accounts
  # bank_name, bank_code, agency, account_number, account_type, pix_key
end

class Address < ContactInfo; end
class Phone < ContactInfo; end  
class Email < ContactInfo; end
class BankAccount < ContactInfo; end
```

### Option B: Separate Polymorphic Models (Recommended)
```ruby
# Base polymorphic association
module Contactable
  extend ActiveSupport::Concern
  
  included do
    has_many :addresses, as: :contactable, dependent: :destroy
    has_many :phones, as: :contactable, dependent: :destroy
    has_many :emails, as: :contactable, dependent: :destroy
    has_many :bank_accounts, as: :contactable, dependent: :destroy
  end
end

# Separate optimized tables
class Address < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  # Specific fields: street, number, complement, neighborhood, city, state, zip_code, country
end

class Phone < ApplicationRecord  
  belongs_to :contactable, polymorphic: true
  
  # Specific fields: number, phone_type, is_primary, is_whatsapp
end

class Email < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  # Specific fields: address, email_type, is_primary, is_verified
end

class BankAccount < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  
  # Specific fields: bank_name, bank_code, agency, account_number, account_type, pix_key
end
```

## Benefits of Option B (Separate Polymorphic Models):

### ✅ **Performance**
- Proper database indexes on specific fields
- Faster queries (no JSON parsing)
- Better query optimization

### ✅ **Validation & Business Logic**
- Field-specific validations (CPF format, email format, etc.)
- Type-specific methods and scopes
- Easier to add contact-type specific features

### ✅ **Flexibility**
- Can add contact-type specific fields easily
- Better data modeling for different contact types
- Polymorphic association allows any entity to have any contact type

### ✅ **Developer Experience**
- IntelliSense/autocomplete works properly
- Type safety
- Clear API: `customer.addresses.create!(street: 'Rua A', city: 'São Paulo')`

## Migration Strategy:

### Phase 1: Create New Polymorphic Models
```ruby
# Create new optimized contact models
rails g model Address contactable:references{polymorphic} street:string number:string ...
rails g model Phone contactable:references{polymorphic} number:string phone_type:string ...
rails g model Email contactable:references{polymorphic} address:string email_type:string ...
rails g model BankAccount contactable:references{polymorphic} bank_name:string ...
```

### Phase 2: Migration Script
```ruby
# Migrate data from legacy tables to new polymorphic structure
CustomerAddress.find_each do |old_address|
  Address.create!(
    contactable: old_address.customer.profile, # Link to IndividualEntity/LegalEntity
    street: old_address.street,
    city: old_address.city,
    # ... other fields
  )
end

# Migrate from ContactInfo JSON to structured models
ContactInfo.addresses.find_each do |contact|
  Address.create!(
    contactable: contact.contactable,
    street: contact.contact_data['street'],
    city: contact.contact_data['city'],
    # ... other fields
  )
end
```

### Phase 3: Update Models
```ruby
class IndividualEntity < ApplicationRecord
  include Contactable  # Gets addresses, phones, emails, bank_accounts associations
end

class LegalEntity < ApplicationRecord  
  include Contactable  # Gets addresses, phones, emails, bank_accounts associations
end

class Admin < ApplicationRecord
  include Contactable  # Gets addresses, phones, emails, bank_accounts associations
end
```

### Phase 4: Clean API
```ruby
# Beautiful, type-safe API
customer = Customer.find(10)
entity = customer.profile

# Add contacts
entity.addresses.create!(street: 'Rua A', number: '123', city: 'São Paulo', state: 'SP')
entity.phones.create!(number: '11987654321', phone_type: 'mobile', is_whatsapp: true)
entity.emails.create!(address: 'user@example.com', email_type: 'personal', is_primary: true)

# Query contacts
entity.addresses.where(city: 'São Paulo')
entity.phones.mobile.primary  
entity.emails.verified
```

## Recommendation: **Go with Option B**

The separate polymorphic models approach provides the best balance of:
- **Performance** (proper indexing, no JSON)  
- **Type Safety** (specific validations per contact type)
- **Flexibility** (easy to extend contact types)
- **Clean API** (intuitive and maintainable)

This eliminates the dual system problem and provides a clean, scalable architecture for contact information.