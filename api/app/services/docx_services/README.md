# DOCX Document Generation Services

This module provides a clean, DRY architecture for generating DOCX documents with proper formatting, translation, and genderization support.

## Architecture Overview

```
app/services/docx/
├── formatter.rb                    # Core formatting utility
├── entity_builder.rb               # Builds formatters from models
├── base_template.rb                # Base class for document services
├── document_deficiency_statement_service.rb
├── power_of_attorney_service.rb
└── social_contract_service.rb
```

## Core Components

### Formatter
Handles all field formatting with proper gender and entity type support:
- Document formatting (CPF, CNPJ, RG, OAB, etc.)
- Address formatting with proper prefixes
- Phone and ZIP code masking
- Full qualification text generation

### EntityBuilder
Extracts data from ActiveRecord models and creates appropriate formatters:
- Auto-detects entity type (person, company, office)
- Handles associations (addresses, emails, phones)
- Supports both hash and model inputs

### BaseTemplate
Provides common functionality for all document services:
- Document processing and substitution
- S3 upload handling
- Standard placeholder replacements
- Extensible architecture for custom documents

## Usage Examples

### Basic Formatting

```ruby
# Format a person's data
formatter = Docx::Formatter.new(
  { 
    name: 'Maria', 
    last_name: 'Santos',
    cpf: '12345678901',
    civil_status: 'single',
    nationality: 'brazilian'
  },
  entity_type: :person,
  gender: :female
)

formatter.full_name        # => "MARIA SANTOS"
formatter.cpf             # => "inscrita no CPF sob o nº 123.456.789-01"
formatter.marital_status  # => "solteira"
formatter.nationality     # => "brasileira"
```

### Using with Models

```ruby
# Build formatter from a model
builder = Docx::EntityBuilder.new
formatter = builder.build(profile_customer)

# Get full qualification
formatter.qualification
# => "JOÃO SILVA, brasileiro, casado, advogado, inscrito no CPF..."
```

### Generating Documents

```ruby
# Generate a power of attorney
Docx::PowerOfAttorneyService.new(document_id).call

# Or use the convenience method
Docx.generate(document_id, 'power_of_attorney')
```

### Creating Custom Documents

```ruby
module Docx
  class ContractService < BaseTemplate
    protected
    
    def template_path
      'app/template_documents/contract.docx'
    end
    
    def substitute_custom_fields(text)
      text.substitute('_contract_date_', contract_date)
      text.substitute('_contract_value_', contract_value)
    end
    
    private
    
    def contract_date
      I18n.l(Time.zone.now, format: '%d de %B de %Y')
    end
    
    def contract_value
      'R$ 10.000,00 (dez mil reais)'
    end
  end
end
```

## Gender Support

The system properly handles gender for Portuguese translations:

- **Male**: advogado, brasileiro, solteiro, inscrito
- **Female**: advogada, brasileira, solteira, inscrita
- **Neutral/Other**: advogado(a), brasileiro(a), solteiro(a), inscrito(a)

## Document Masks

All Brazilian documents are properly masked:

- **CPF**: 123.456.789-01
- **CNPJ**: 12.345.678/0001-01
- **CEP**: 12345-678
- **Phone**: (11) 98765-4321
- **NB**: 123.4567.8901-2
- **NIT**: 123.45678.90-1

## Template Placeholders

Common placeholders available in all templates:

- `_proc_today_`: Current date with location
- `_proc_full_name_`: Customer full name
- `_proc_outorgante_`: Client qualification
- `_proc_outorgado_`: Lawyers qualification
- `_proc_job_`: Work description

## Error Handling

The services include proper error handling:
- File operations are properly closed
- S3 uploads are logged
- Temporary files are cleaned up
- Errors are logged with context

## Testing

```ruby
# Test formatter
formatter = Docx::Formatter.new(test_data, gender: :female)
expect(formatter.cpf).to eq("inscrita no CPF sob o nº 123.456.789-01")

# Test document generation
service = Docx::PowerOfAttorneyService.new(document.id)
expect(service.call).to be_truthy
```

## Dependencies

- `docx` gem for document manipulation
- Rails I18n for translations
- S3Service for document storage
- ActiveRecord models (Document, Work, ProfileCustomer, etc.)