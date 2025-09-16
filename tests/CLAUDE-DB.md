# Database Testing Guidelines

## Stack
- PostgreSQL
- Database Cleaner for test isolation
- Factory Bot for test data creation

## Database Testing Best Practices

### Test Isolation
- Use transactional fixtures for speed
- Clean database between tests with DatabaseCleaner
- Test database constraints and validations
- Verify proper use of database indexes
- Test migrations and schema changes

### Test Data Management
- Use factories (FactoryBot) for creating test data
- Create minimal data needed for each test
- Avoid dependencies between tests
- Clean up after tests

### Factory Bot Guidelines

#### Creating Factories
```ruby
FactoryBot.define do
  factory :customer do
    name { Faker::Name.full_name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    
    trait :with_profile do
      after(:create) do |customer|
        create(:profile, customer: customer)
      end
    end
    
    trait :active do
      status { 'active' }
    end
  end
end
```

#### Using Factories in Tests
```ruby
# Basic creation
customer = create(:customer)

# With traits
customer = create(:customer, :with_profile, :active)

# Build without saving
customer = build(:customer)

# Build stubbed (without touching database)
customer = build_stubbed(:customer)

# Create lists
customers = create_list(:customer, 5)

# Override attributes
customer = create(:customer, name: 'John Doe')
```

### Database Constraints Testing
```ruby
describe Customer do
  it 'requires unique email' do
    create(:customer, email: 'test@example.com')
    
    expect {
      create(:customer, email: 'test@example.com')
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
  
  it 'validates email format' do
    customer = build(:customer, email: 'invalid-email')
    expect(customer).not_to be_valid
    expect(customer.errors[:email]).to include('is invalid')
  end
end
```

### Migration Testing
```ruby
# Test migration behavior
describe 'AddIndexToCustomersEmail migration' do
  it 'adds index to customers email column' do
    connection = ActiveRecord::Base.connection
    expect(connection.index_exists?(:customers, :email)).to be true
  end
end

# Test data migration
describe 'MigrateCustomerData migration' do
  before do
    # Create test data in old format
    customer = create(:customer, old_field: 'value')
  end
  
  it 'migrates data correctly' do
    # Run migration
    migration = MigrateCustomerData.new
    migration.up
    
    # Verify migration
    customer.reload
    expect(customer.new_field).to eq('value')
    expect(customer.old_field).to be_nil
  end
end
```

### Database Performance Testing
```ruby
describe 'Customer queries' do
  it 'executes search query efficiently' do
    create_list(:customer, 100)
    
    expect {
      Customer.search('John').limit(10).to_a
    }.to make_database_queries(count: 1)
  end
  
  it 'uses proper indexes' do
    # Verify query plan uses index
    plan = Customer.connection.execute(
      "EXPLAIN ANALYZE SELECT * FROM customers WHERE email = 'test@example.com'"
    )
    expect(plan.to_a.first['QUERY PLAN']).to include('Index Scan')
  end
end
```

### Transaction Testing
```ruby
describe 'Customer creation with profile' do
  it 'rolls back transaction on failure' do
    expect {
      Customer.transaction do
        customer = create(:customer)
        # Simulate failure
        raise ActiveRecord::Rollback if customer.email.blank?
      end
    }.not_to change(Customer, :count)
  end
end
```

### Database Cleaner Configuration
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

### Edge Cases to Test
Always test:
- Nil/empty values
- Boundary conditions
- Invalid inputs
- Foreign key constraints
- Unique constraints
- Database triggers
- Cascading deletes

### Performance Considerations
1. Use transactional fixtures/database cleaner for backend tests
2. Minimize database queries in tests
3. Use `build_stubbed` when database persistence isn't needed
4. Profile slow tests and optimize
5. Consider using separate test database for parallelization

Remember: Database tests should verify data integrity, constraints, and business logic at the persistence layer.