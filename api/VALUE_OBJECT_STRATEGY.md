# Value Object Implementation Strategy for ProcStudio API

## Current State Analysis

Your codebase heavily relies on **primitive string types** for critical business domains:
- **Brazilian Documents**: CPF, CNPJ, RG stored as strings
- **Contact Information**: Email, Phone stored as strings  
- **Addresses**: All fields (street, city, zip_code) stored as strings

While you have good validation logic (concerns like `CnpjValidatable`, validators like `CpfValidator`), the code violates the **Primitive Obsession** anti-pattern.

## Problems with Current Approach

1. **Type Safety**: No compile-time or runtime guarantees about data format
2. **Scattered Logic**: Validation, formatting, and normalization spread across models
3. **Duplicated Code**: Similar validation patterns repeated
4. **Weak Domain Model**: Business rules not encapsulated with data
5. **Error-Prone**: Easy to pass wrong string to wrong field

## Proposed Value Object Architecture

### Core Value Object Base Class

```ruby
# app/models/value_objects/base.rb
module ValueObjects
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization

    def initialize(value)
      @raw_value = value
      @value = normalize(value) if value.present?
      validate!
    end

    def to_s
      @value.to_s
    end

    def to_param
      @value.to_s
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      @value == other.value
    end

    def present?
      @value.present?
    end

    def blank?
      @value.blank?
    end

    protected

    attr_reader :value

    def normalize(value)
      value
    end

    def validate!
      # Override in subclasses
    end
  end
end
```

### Implementation Examples

#### 1. CPF Value Object

```ruby
# app/models/value_objects/cpf.rb
module ValueObjects
  class Cpf < Base
    CPF_FORMAT = /\A\d{11}\z/
    
    def formatted
      return nil if blank?
      "#{@value[0..2]}.#{@value[3..5]}.#{@value[6..8]}-#{@value[9..10]}"
    end

    def obfuscated
      return nil if blank?
      "***.***.#{@value[6..8]}-**"
    end

    private

    def normalize(value)
      value.to_s.gsub(/\D/, '')
    end

    def validate!
      return if @value.blank?
      
      unless @value.match?(CPF_FORMAT)
        raise ArgumentError, "Invalid CPF format"
      end

      unless valid_checksum?
        raise ArgumentError, "Invalid CPF checksum"
      end

      if all_digits_same?
        raise ArgumentError, "Invalid CPF - all digits are the same"
      end
    end

    def valid_checksum?
      # Existing checksum logic from CpfValidator
      first_digit_valid? && second_digit_valid?
    end

    def all_digits_same?
      @value.chars.uniq.size == 1
    end

    # ... checksum calculation methods ...
  end
end
```

#### 2. Email Value Object

```ruby
# app/models/value_objects/email.rb
module ValueObjects
  class Email < Base
    EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

    def domain
      @value.split('@').last
    end

    def local_part
      @value.split('@').first
    end

    def obfuscated
      return nil if blank?
      parts = @value.split('@')
      local = parts[0]
      domain = parts[1]
      
      if local.length <= 3
        "***@#{domain}"
      else
        "#{local[0..2]}***@#{domain}"
      end
    end

    private

    def normalize(value)
      value.to_s.downcase.strip
    end

    def validate!
      return if @value.blank?
      
      unless @value.match?(EMAIL_REGEX)
        raise ArgumentError, "Invalid email format"
      end
    end
  end
end
```

#### 3. Address Value Object

```ruby
# app/models/value_objects/address.rb
module ValueObjects
  class Address < Base
    attr_reader :street, :number, :complement, :neighborhood, 
                :city, :state, :zip_code, :country

    def initialize(attributes = {})
      @street = attributes[:street]
      @number = attributes[:number]
      @complement = attributes[:complement]
      @neighborhood = attributes[:neighborhood]
      @city = attributes[:city]
      @state = attributes[:state]
      @zip_code = normalize_zip(attributes[:zip_code])
      @country = attributes[:country] || 'BR'
      validate!
    end

    def formatted
      parts = []
      parts << "#{street}, #{number}" if street.present?
      parts << complement if complement.present?
      parts << neighborhood if neighborhood.present?
      parts << "#{city}/#{state}" if city.present? && state.present?
      parts << formatted_zip if zip_code.present?
      parts.join(', ')
    end

    def formatted_zip
      return nil if zip_code.blank?
      "#{zip_code[0..4]}-#{zip_code[5..7]}"
    end

    def complete?
      street.present? && number.present? && city.present? && 
      state.present? && zip_code.present?
    end

    private

    def normalize_zip(value)
      value.to_s.gsub(/\D/, '') if value.present?
    end

    def validate!
      if zip_code.present? && !zip_code.match?(/\A\d{8}\z/)
        raise ArgumentError, "Invalid ZIP code format"
      end

      if state.present? && !valid_brazilian_state?
        raise ArgumentError, "Invalid Brazilian state"
      end
    end

    def valid_brazilian_state?
      %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO].include?(state)
    end
  end
end
```

### ActiveRecord Integration

#### Custom Type for Attributes API

```ruby
# app/models/types/cpf_type.rb
module Types
  class CpfType < ActiveRecord::Type::Value
    def cast(value)
      return nil if value.nil?
      return value if value.is_a?(ValueObjects::Cpf)
      
      ValueObjects::Cpf.new(value)
    rescue ArgumentError => e
      raise ActiveRecord::RecordInvalid, e.message
    end

    def serialize(value)
      return nil if value.nil?
      value.to_s
    end

    def deserialize(value)
      return nil if value.nil?
      ValueObjects::Cpf.new(value)
    end
  end
end
```

#### Model Implementation

```ruby
# app/models/profile_customer.rb
class ProfileCustomer < ApplicationRecord
  # Register custom types
  attribute :cpf, Types::CpfType.new
  attribute :cnpj, Types::CnpjType.new
  
  # Or use composed_of for complex value objects
  composed_of :primary_address,
              class_name: 'ValueObjects::Address',
              mapping: [
                %w[street street],
                %w[number number],
                %w[complement complement],
                %w[neighborhood neighborhood],
                %w[city city],
                %w[state state],
                %w[zip_code zip_code]
              ],
              allow_nil: true

  # Validations become simpler
  validate :document_presence

  private

  def document_presence
    if physical_person?
      errors.add(:cpf, "can't be blank") if cpf.blank?
    else
      errors.add(:cnpj, "can't be blank") if cnpj.blank?
    end
  end
end
```

### Serializer Integration

```ruby
# app/serializers/profile_customer_serializer.rb
class ProfileCustomerSerializer < ActiveModel::Serializer
  attributes :id, :name

  attribute :cpf do
    object.cpf&.formatted
  end

  attribute :cpf_obfuscated do
    object.cpf&.obfuscated
  end

  attribute :primary_address do
    {
      formatted: object.primary_address&.formatted,
      complete: object.primary_address&.complete?
    }
  end
end
```

## Migration Strategy

### Phase 1: Foundation (Week 1)
1. Create `ValueObjects::Base` class
2. Implement core value objects (Cpf, Cnpj, Email)
3. Create ActiveRecord type classes
4. Write comprehensive specs

### Phase 2: Gradual Adoption (Week 2-3)
1. Start with new features - use value objects immediately
2. Migrate critical models one at a time:
   - User/Customer (Email)
   - ProfileCustomer (CPF/CNPJ)
   - Office (CNPJ)

### Phase 3: Full Migration (Week 4-6)
1. Replace all primitive usages
2. Remove old validation concerns/validators
3. Update all serializers
4. Refactor service objects

### Phase 4: Advanced Features (Optional)
1. Add value object collections
2. Implement query methods for value objects
3. Add database-level custom types (PostgreSQL)

## Implementation Checklist

- [ ] Create `app/models/value_objects/` directory
- [ ] Implement `Base` value object
- [ ] Create value objects for:
  - [ ] CPF
  - [ ] CNPJ
  - [ ] Email
  - [ ] Phone
  - [ ] Address
  - [ ] ZipCode
- [ ] Create ActiveRecord type classes
- [ ] Write RSpec shared examples for value objects
- [ ] Create factory support for value objects
- [ ] Update model validations
- [ ] Update serializers
- [ ] Add controller parameter handling
- [ ] Document value object usage

## Benefits After Implementation

1. **Type Safety**: Impossible to assign invalid values
2. **Encapsulation**: All logic in one place
3. **Immutability**: Value objects are immutable by design
4. **Testability**: Easy to test in isolation
5. **Reusability**: Same value object across models
6. **Domain Clarity**: Code expresses business domain better
7. **Reduced Bugs**: Validation happens at construction time

## Example Usage After Migration

```ruby
# Before (Primitive)
customer = ProfileCustomer.new(cpf: "123.456.789-00")
customer.cpf # => "12345678900" (normalized string)
customer.cpf_formatted # => Need method in model

# After (Value Object)
customer = ProfileCustomer.new(cpf: "123.456.789-00")
customer.cpf.formatted # => "123.456.789-00"
customer.cpf.obfuscated # => "***.456.789-**"
customer.cpf == ValueObjects::Cpf.new("12345678900") # => true

# Invalid values fail immediately
customer = ProfileCustomer.new(cpf: "invalid")
# => Raises ArgumentError: "Invalid CPF format"
```

## Testing Strategy

```ruby
# spec/models/value_objects/cpf_spec.rb
RSpec.describe ValueObjects::Cpf do
  it_behaves_like 'a value object'
  
  describe 'validation' do
    it 'accepts valid CPF' do
      expect { described_class.new('11144477735') }.not_to raise_error
    end

    it 'rejects invalid CPF' do
      expect { described_class.new('11111111111') }
        .to raise_error(ArgumentError, /Invalid CPF/)
    end
  end

  describe '#formatted' do
    subject { described_class.new('11144477735') }
    
    it 'returns formatted CPF' do
      expect(subject.formatted).to eq('111.444.777-35')
    end
  end
end
```

## Database Considerations

While value objects are Ruby constructs, consider these database optimizations:

1. **Indexes**: Keep indexes on raw string columns
2. **Constraints**: Add CHECK constraints for format validation
3. **Triggers**: Optional - validate format at database level
4. **Custom Types**: PostgreSQL supports custom types for advanced usage

```sql
-- Example PostgreSQL constraint
ALTER TABLE profile_customers 
ADD CONSTRAINT valid_cpf_format 
CHECK (cpf ~ '^\d{11}$');
```

## Rollback Strategy

If issues arise, you can temporarily:
1. Keep both patterns working in parallel
2. Add delegation methods to maintain API compatibility
3. Use feature flags to toggle between implementations

```ruby
class ProfileCustomer < ApplicationRecord
  if Feature.value_objects_enabled?
    attribute :cpf, Types::CpfType.new
  else
    validates :cpf, cpf: true
  end
  
  # Backward compatibility
  def cpf_formatted
    cpf.is_a?(ValueObjects::Cpf) ? cpf.formatted : format_legacy_cpf
  end
end
```

## Conclusion

Implementing value objects will transform your codebase from using primitive strings to rich domain objects that encapsulate behavior and validation. This approach:
- Eliminates primitive obsession
- Centralizes business logic
- Improves type safety
- Makes the domain model more expressive

Start with high-impact, frequently-used types (CPF, CNPJ, Email) and gradually expand to cover all domain primitives.