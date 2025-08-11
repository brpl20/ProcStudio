# Customer Detail Display Methods

This document explains how to use the new Customer detail display methods for viewing comprehensive information about customers and their associated entities.

## Available Methods

### 1. `show_details` (or `details` / `info`)
Displays formatted customer information in the console.

```ruby
# Usage in Rails Console
customer = Customer.find(10)
customer.show_details
# or
customer.details
# or 
customer.info
```

### 2. `full_details`
Returns all customer information as a structured hash (useful for APIs).

```ruby
customer = Customer.find(10)
details_hash = customer.full_details
```

## What Information is Displayed

### For All Customers:
- Customer ID, Email, Status
- Team information
- Creation and confirmation dates

### For Individual Entity Customers:
- **Personal Information:**
  - Full name
  - CPF (formatted: 123.456.789-01)
  - RG
  - Birth date and age
  - Gender, nationality, civil status
  - Profession
  - Mother's name
  - NIT and INSS information

### For Legal Entity Customers:
- **Company Information:**
  - Company name
  - CNPJ (formatted: 12.345.678/0001-90)
  - State registration
  - Entity type (law_firm, company, office)
  - Status and accounting type
  - Number of partners
  - Legal representative

### For Law Office Customers (LegalEntity with office):
- **Law Office Information:**
  - OAB registration ID
  - Inscription number
  - Legal specialty
  - Society link
  - **Lawyers and Partners:**
    - Lawyer names and CPFs
    - Partnership types (sócio, associado, sócio de serviço)
    - Ownership percentages
    - Total ownership percentage

### Contact Information (for all entity types):
- **Addresses:** Street, number, neighborhood, city, state, CEP
- **Phones:** Numbers with type (mobile, commercial, etc.)
- **Emails:** Email addresses with type
- **Bank Accounts:** Bank details, agency, account numbers

## Usage Examples

### Individual Entity Customer
```ruby
# Find an individual customer
customer = Customer.where(profile_type: 'IndividualEntity').first
customer.show_details

# Output will show:
# - Customer information
# - Personal details (CPF, RG, birth date, etc.)
# - Contact information (addresses, phones, emails)
```

### Legal Entity Customer (Company)
```ruby
# Find a legal entity customer
customer = Customer.where(profile_type: 'LegalEntity').first
customer.show_details

# Output will show:
# - Customer information
# - Company details (CNPJ, entity type, etc.)
# - Contact information
```

### Law Office Customer
```ruby
# Find a law office customer
law_office_customer = Customer.joins(profile: :legal_entity_office).first
law_office_customer.show_details

# Output will show:
# - Customer information
# - Company details
# - Law office specific information
# - Lawyers and partnership details
# - Contact information
```

### Getting Data as Hash (for APIs)
```ruby
customer = Customer.find(10)
data = customer.full_details

# Returns structured hash with:
# - customer: basic customer info
# - profile_type: "IndividualEntity" or "LegalEntity"
# - profile: entity-specific information
# - contact_info: addresses, phones, emails, bank_accounts
# - law_office: (if applicable) office and lawyer details

# Convert to JSON
require 'json'
json_data = JSON.pretty_generate(data)
puts json_data
```

## Finding Customers by Type

### Find Individual Entity Customers
```ruby
individual_customers = Customer.where(profile_type: 'IndividualEntity')
individual_customers.each { |c| c.show_details }
```

### Find Legal Entity Customers
```ruby
legal_customers = Customer.where(profile_type: 'LegalEntity')
legal_customers.each { |c| c.show_details }
```

### Find Law Office Customers
```ruby
law_office_customers = Customer.joins(profile: :legal_entity_office)
law_office_customers.each { |c| c.show_details }
```

## Helper Methods on Customer

### Check Entity Type
```ruby
customer = Customer.find(10)

customer.individual_entity?  # returns true/false
customer.legal_entity?       # returns true/false
customer.entity_name         # returns formatted name
```

### Access Profile Directly
```ruby
customer = Customer.find(10)

# Access the polymorphic profile
if customer.individual_entity?
  individual = customer.profile
  puts individual.full_name
  puts individual.cpf
elsif customer.legal_entity?
  company = customer.profile
  puts company.name
  puts company.cnpj
  
  # Check if it's a law office
  if company.is_law_office?
    office = company.legal_entity_office
    puts "OAB: #{office.oab_id}"
    puts "Lawyers: #{office.lawyers.count}"
  end
end
```

## Output Example

```
================================================================================
                                CUSTOMER DETAILS                                
================================================================================

------------------------------CUSTOMER INFORMATION------------------------------
ID: 6
Email: filiberto.tremblay@schmitt.example
Status: active
Team: Development Team
Created: 2025-08-10 18:52
Confirmed: 2025-08-10 18:52

-----------------------COMPANY INFORMATION (Legal Entity)-----------------------
Company Name: Mendanha & Vasques Advogados
CNPJ: 65.235.380/0001-89
State Registration: 979469987
Entity Type: Law firm
Status: active
Accounting Type: Lucro real
Number of Partners: 4
Legal Representative: João Silva Advogado

ADDRESSES:
  1. [PRIMARY] 
     Av. Paulista, 1000 - Conjunto 101
     Bela Vista, São Paulo - SP
     CEP: 01310-100
     Country: Brasil

PHONES:
  1. [PRIMARY] (11) 3456-7890 (commercial)

EMAILS:
  1. [PRIMARY] contato@mendanhaevasques.com.br (commercial)

-----------------------------LAW OFFICE INFORMATION-----------------------------
OAB ID: OAB/SP 973840
Inscription Number: 6401/2025
Legal Specialty: Tributário

LAWYERS AND PARTNERS:
  • João Silva Advogado
    CPF: 188.468.058-52
    Type: Socio
    Ownership: 40.0%
  • João Guilherme Gentil Advogado
    CPF: 982.310.893-57
    Type: Socio de servico
    Ownership: 30.0%
  Total Ownership: 85.0%
================================================================================
```

## Notes
- All Brazilian documents (CPF, CNPJ, CEP) are automatically formatted for display
- Phone numbers are formatted with Brazilian standards
- The methods handle missing data gracefully (shows "Not provided" or "None registered")
- Primary contact information is clearly marked with [PRIMARY] tag
- The `show_details` method returns `nil` to avoid cluttering the console output