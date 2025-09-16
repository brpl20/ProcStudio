# Rails Testing Guidelines

## Stack & Version
- Rails 8.0.0
- Ruby 3.2.7
- RSpec 6.0.0
- Factory Bot for test data
- Database Cleaner for test isolation

## RSpec Best Practices

### Structure & Organization
- Use `describe` for classes/methods, `context` for different scenarios
- Follow the AAA pattern: Arrange, Act, Assert
- Keep specs focused - one behavior per example
- Use descriptive test names that read like documentation

```ruby
# Good example
describe '#calculate_total' do
  context 'when discount is applied' do
    it 'subtracts discount from sum of items' do
      # Arrange
      order = create(:order, items: [item1, item2])
      discount = create(:discount, amount: 10)

      # Act
      result = order.calculate_total(discount: discount)

      # Assert
      expect(result).to eq(90)
    end
  end
end
```

### Key Patterns
- Use facades to keep tests organized
- Create full tests with one command, but still make possible to isolate testes easilly
- Use `let` and `let!` for lazy and eager loading test data
- Prefer `subject` for the object under test
- Use shared examples for common behaviors
- Utilize custom matchers for complex assertions
- Mock external services and API calls
- Use FactoryBot for creating test data
- Apply database cleaner strategies appropriately

### Integration Tests

#### Full Stack Integration Testing
- Test complete user workflows end-to-end
- Verify database transactions and rollbacks
- Test background jobs integration (Sidekiq)
- Validate external service integrations
- Check caching mechanisms

```ruby
# Integration test example
RSpec.describe 'Customer Registration Flow', type: :integration do
  it 'completes full registration process' do
    # Step 1: User signs up
    post '/api/v1/auth/signup', params: {
      user: { email: 'new@example.com', password: 'password123' }
    }
    expect(response).to have_http_status(:created)
    user = User.last

    # Step 2: Email confirmation job is queued
    expect(UserMailerJob).to have_been_enqueued.with(user.id)

    # Step 3: User confirms email
    get "/api/v1/auth/confirm?token=#{user.confirmation_token}"
    expect(response).to have_http_status(:ok)
    expect(user.reload).to be_confirmed

    # Step 4: User creates profile
    post '/api/v1/profile', params: {
      profile: { first_name: 'John', last_name: 'Doe' }
    }, headers: { 'Authorization' => "Bearer #{user.token}" }
    expect(response).to have_http_status(:created)

    # Step 5: Verify complete setup
    expect(user.profile).to be_present
    expect(user.profile.first_name).to eq('John')
  end
end
```

### Minitest Best Practices
*Note: This project uses RSpec, but for reference:*

- Use descriptive test method names
- Organize tests in logical test classes
- Use setup and teardown hooks appropriately
- Leverage assertions effectively
- Keep tests isolated and independent

## Performance Considerations
1. Use transactional fixtures/database cleaner for backend tests
2. Avoid hitting external services (use VCR or mocks)
3. Minimize database queries in tests
4. Run tests in parallel when possible
5. Profile slow tests and optimize

## Coverage Guidelines
- Aim for high coverage but focus on meaningful tests
- Test all public methods and components
- Test edge cases and error conditions
- Don't test framework code (Rails internals)
- Focus on business logic coverage

Remember: Good tests are documentation. They should clearly show what the code is supposed to do.