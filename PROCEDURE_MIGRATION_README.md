# Procedure Migration Documentation

## Overview
This migration introduces a new hierarchical structure for managing legal procedures within Works. The main changes include:

1. **Procedures Model**: Works can now have multiple procedures (administrative, judicial, extrajudicial)
2. **Hierarchical Structure**: Procedures can have child procedures using the ancestry gem
3. **Procedural Parties**: Support for plaintiffs and defendants with polymorphic associations
4. **Enhanced Honorary System**: Honoraries can be attached at Work level (global) or Procedure level
5. **Legal Costs Management**: Comprehensive Brazilian legal cost tracking system

## Migration Files

### 1. CreateProcedures (20250829144713)
Creates the main procedures table with:
- Hierarchical support via ancestry
- Location fields (city, state)
- System and competence tracking
- Financial values (claim, conviction, received)
- Status management
- Priority handling

### 2. CreateProceduralParties (20250829144812)
Creates the procedural parties table for managing plaintiffs and defendants:
- Polymorphic association to ProfileCustomer
- Support for external parties (just names)
- Primary party designation
- CPF/CNPJ and OAB number tracking

### 3. UpdateHonorariesStructure (20250829144849)
Updates honoraries to support both Work and Procedure attachment:
- Adds procedure_id reference
- Makes work_id optional
- Adds status and description fields
- Ensures honorary is attached to either work or procedure

### 4. CreateHonoraryComponents (20250829144933)
Creates flexible honorary component system:
- JSONB storage for component details
- Support for multiple fee types (fixed, hourly, success, etc.)
- Active/inactive status
- Position-based ordering

### 5. CreateLegalCosts (20250829145005)
Creates comprehensive legal cost tracking:
- Legal cost management per honorary
- Individual cost entries with Brazilian tax types
- Payment tracking and status
- Admin fee calculation

### 6. UpdateWorksRemoveProcedureFields (20250829145045)
Removes procedure-specific fields from Works table:
- Removes procedure enum
- Removes status field
- Adds work_status field

### 7. MigrateExistingWorksToProcedures (20250829145756)
Data migration to create procedures for existing works:
- Creates one procedure per existing work
- Preserves existing data
- Maintains honorary relationships

## Models

### Procedure
```ruby
# Key associations
belongs_to :work
has_many :procedural_parties
has_many :honoraries
has_ancestry # For hierarchical structure

# Key methods
procedure.add_plaintiff(customer_or_name, attributes)
procedure.add_defendant(customer_or_name, attributes)
procedure.create_child_procedure(attributes)
procedure.financial_summary
```

### ProceduralParty
```ruby
# Polymorphic association
belongs_to :partyable, polymorphic: true # Can be ProfileCustomer
belongs_to :procedure

# Party types
enum party_type: { plaintiff: 'plaintiff', defendant: 'defendant' }
```

### Honorary
```ruby
# Can be attached to Work or Procedure
belongs_to :work, optional: true
belongs_to :procedure, optional: true
has_many :components
has_one :legal_cost

# Key methods
honorary.add_component(type, details)
honorary.total_estimated_value
honorary.is_global? # Work-level
honorary.is_procedure_specific?
```

### HonoraryComponent
```ruby
# Component types
COMPONENT_TYPES = [
  'fixed_fee',
  'hourly_rate',
  'monthly_retainer',
  'success_fee',
  'performance_fee',
  'consultation_fee',
  'previdenciario_fee',
  'sucumbencia_fee'
]

# JSONB details storage with validation
validates :details # Schema validation per component type
```

### LegalCost & LegalCostEntry
```ruby
# Brazilian legal cost types
BRAZILIAN_COST_TYPES = {
  custas_judiciais: 'Custas Judiciais',
  taxa_judiciaria: 'Taxa Judiciária',
  # ... etc
}

# Payment tracking
legal_cost_entry.mark_as_paid!(payment_date: Date.current)
legal_cost.total_with_admin_fee
```

## Usage Examples

### Creating a Work with Procedures
```ruby
work = Work.create!(
  law_area: law_area,
  team: team,
  work_status: 'active'
)

# Add a judicial procedure
procedure = work.add_procedure('judicial',
  number: '1234567-89.2024.8.16.0000',
  city: 'Cascavel',
  state: 'PR',
  system: 'Projudi',
  competence: 'Justiça Estadual',
  claim_value: 100000.00
)

# Add parties
procedure.add_plaintiff(customer, is_primary: true)
procedure.add_defendant('João da Silva', cpf_cnpj: '123.456.789-00')

# Create child procedure (appeal, for example)
appeal = procedure.create_child_procedure(
  procedure_type: 'judicial',
  number: '9876543-21.2024.8.16.0000',
  status: 'in_progress'
)
```

### Managing Honoraries
```ruby
# Global honorary (Work level)
global_honorary = work.honoraries.create!(
  name: 'Honorários Globais',
  status: 'active'
)

# Add fixed fee component
global_honorary.add_component('fixed_fee', {
  amount: 5000.00,
  payment_terms: 'À vista',
  installments: 1
})

# Procedure-specific honorary
procedure_honorary = procedure.honoraries.create!(
  name: 'Honorários de Êxito',
  work: work, # Still reference the work
  status: 'active'
)

# Add success fee component
procedure_honorary.add_component('success_fee', {
  percentage: 30,
  base_calculation: 'valor_da_condenacao',
  minimum_amount: 10000.00
})
```

### Legal Costs Management
```ruby
legal_cost = honorary.create_legal_cost(
  client_responsible: true,
  include_in_invoices: true,
  admin_fee_percentage: 10
)

# Add cost entries
legal_cost.add_entry('custas_judiciais',
  'Custas Iniciais',
  500.00,
  due_date: 10.days.from_now
)

legal_cost.add_entry('taxa_judiciaria',
  'Taxa de Distribuição',
  250.00,
  estimated: false,
  paid: true,
  payment_date: Date.current
)

# Check financial summary
legal_cost.summary
# => { total: 750.00, paid: 250.00, pending: 500.00, ... }
```

## Running the Migrations

1. Install the ancestry gem:
```bash
bundle install
```

2. Run the migrations:
```bash
rails db:migrate
```

3. The data migration will automatically:
   - Create one procedure for each existing work
   - Preserve existing honorary relationships
   - Maintain all existing data

## Rollback Considerations

- The data migration is marked as irreversible to prevent data loss
- To rollback, you would need to manually handle data preservation
- Consider backing up the database before running migrations

## Testing

After migration, test the following:

1. Existing works have at least one procedure
2. Honoraries are properly associated
3. New procedures can be created with parties
4. Hierarchical procedures work correctly
5. Legal costs can be tracked

## Notes

- The system maintains backward compatibility where possible
- Work status has been renamed to work_status to avoid conflicts
- Procedures have their own status independent of Work status
- The ancestry gem provides efficient tree operations for procedures