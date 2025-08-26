# API Tests

This directory contains direct API tests for the ProcStudio Rails backend, generated from the Postman collection.

## Overview

The API tests are automatically generated from the `collection.json` file in the project root. They test the Rails API endpoints directly without any frontend interaction.

## Structure

```
api/
├── README.md                 # This file
├── generate_tests.js         # Test generator script
├── run_all.js               # Generated test runner
├── test_helper.js           # Generated helper utilities
├── environment.js           # Generated environment config
├── .mocharc.json           # Mocha configuration
└── *_test.js               # Generated test files (one per collection folder)
```

## Getting Started

### Prerequisites

1. **Rails Server**: Ensure the Rails server is running
   ```bash
   cd ../..  # Go to project root
   bundle exec rails server
   ```

2. **Test Database**: Ensure test database is set up
   ```bash
   RAILS_ENV=test bundle exec rails db:create db:migrate
   ```

3. **Dependencies**: Install test dependencies
   ```bash
   npm install
   ```

### Generate Tests

Generate API tests from the collection.json file:

```bash
node generate_tests.js
```

This will:
- Parse the Postman collection
- Generate test files for each collection folder
- Create helper utilities and configuration files
- Display a summary of generated tests

### Run Tests

Run all API tests:
```bash
npm run test:api
# or
node run_all.js
```

Run specific test file:
```bash
npx mocha development_user_users_test.js
```

Run tests with specific reporter:
```bash
npx mocha --reporter json > results.json
```

## Test Structure

Each generated test file follows this pattern:

```javascript
describe('Folder Name', function() {
  this.timeout(30000);

  before(async function() {
    // Authentication setup
  });

  it('Request Name', async function() {
    // Test implementation
    const response = await axios({...});
    validateResponse(response);
  });
});
```

## Authentication

Tests automatically handle authentication using the configuration in `../test_config.json`:

```json
{
  "api": {
    "auth": {
      "type": "bearer",
      "tokenEndpoint": "/auth/login",
      "testCredentials": {
        "email": "test@procstudio.com.br",
        "password": "testpass123"
      }
    }
  }
}
```

## Test Helpers

### Available Helper Functions

- `authenticate()` - Get authentication token
- `request(method, endpoint, data, headers)` - Make authenticated request
- `validateResponse(response, expectedStatus)` - Basic response validation
- `validateJsonApiResponse(response, options)` - JSON:API format validation
- `validateErrorResponse(error, expectedStatus)` - Error response validation
- `generateTestData()` - Generate unique test data
- `checkServerHealth()` - Check if Rails server is running

### Usage Example

```javascript
const { apiHelper, validateJsonApiResponse } = require('./test_helper');

it('should list users', async function() {
  await apiHelper.authenticate();
  const response = await apiHelper.request('GET', '/users');
  validateJsonApiResponse(response, { minCount: 1 });
});
```

## Configuration

### Environment Variables

- `BASE_URL` - Rails API base URL (default: http://localhost:3000)
- `NODE_ENV` - Test environment (default: test)
- `TEST_ADMIN_EMAIL` - Admin test user email
- `TEST_ADMIN_PASSWORD` - Admin test user password

### Test Configuration

Modify `../test_config.json` to customize:

- API endpoints and timeouts
- Authentication settings
- Test credentials
- Response validation options

## Validation Patterns

### Basic Response Validation
```javascript
validateResponse(response, 200);
// Checks: status code, response exists
```

### JSON:API Validation
```javascript
validateJsonApiResponse(response, {
  status: 200,
  minCount: 1,
  expectMeta: true
});
// Checks: JSON:API format, data structure, counts, meta
```

### Error Response Validation
```javascript
try {
  await apiHelper.request('POST', '/invalid');
} catch (error) {
  validateErrorResponse(error, 422);
  // Checks: error status, error format
}
```

## Generated Test Files

Each folder in the Postman collection generates a corresponding test file:

- `development_user_users_test.js` - User management endpoints
- `development_user_profiles_test.js` - Profile management
- `development_user_teams_test.js` - Team management
- `development_user_cases_test.js` - Case management
- etc.

## Debugging Tests

### Verbose Output
```bash
DEBUG=* npx mocha your_test.js
```

### Individual Test
```bash
npx mocha your_test.js --grep "specific test name"
```

### Inspect Responses
```javascript
it('debug test', async function() {
  const response = await apiHelper.request('GET', '/users');
  console.log('Response:', JSON.stringify(response.data, null, 2));
});
```

## Common Issues

### Authentication Failures
- Check test credentials in `test_config.json`
- Ensure Rails server is running
- Verify authentication endpoint is correct

### Connection Errors
- Confirm Rails server is running on correct port
- Check firewall/network settings
- Verify database is accessible

### Test Failures
- Check Rails logs for server-side errors
- Verify test data exists in database
- Confirm API endpoints match collection URLs

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Run API Tests
  run: |
    cd tests
    npm install
    node generate_tests.js
    npm run test:api
  env:
    BASE_URL: http://localhost:3000
    RAILS_ENV: test
```

### Test Reports
```bash
# Generate HTML report
npx mocha --reporter mochawesome

# Generate JUnit XML for CI
npx mocha --reporter xunit --reporter-options output=results.xml
```

## Maintenance

### Regenerating Tests
When the Postman collection is updated:

1. Update `collection.json` in project root
2. Regenerate tests: `node generate_tests.js`
3. Review generated files for any manual adjustments needed
4. Run tests to ensure everything works

### Adding Custom Tests
You can add custom tests alongside generated ones:

```javascript
// custom_api_test.js
const { apiHelper } = require('./test_helper');

describe('Custom API Tests', function() {
  // Your custom test implementations
});
```

## Support

For issues with:
- Test generation: Check `collection.json` format
- Authentication: Verify credentials and Rails auth setup
- Failures: Check Rails server logs and database state

See the main project README for additional setup and troubleshooting information.