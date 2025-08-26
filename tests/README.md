# ProcStudio Test Router 🧪

A comprehensive testing framework that centralizes all testing for the ProcStudio application (Rails API + Svelte Frontend).

## Overview

This test router provides a unified interface to run different types of tests, ensuring comprehensive coverage of your full-stack application:

- **Unit Tests** - Rails RSpec tests for backend logic
- **API Tests** - Direct API endpoint testing (generated from Postman collection)
- **API-Svelte Tests** - Frontend-backend integration testing
- **End-to-End Tests** - Full user workflow testing with Playwright

## Quick Start

### Prerequisites

1. **Rails Server** running on port 3000:
   ```bash
   bundle exec rails server
   ```

2. **Svelte Frontend** running on port 5173:
   ```bash
   cd frontend && npm run dev
   ```

3. **Test Dependencies** installed:
   ```bash
   cd tests
   npm install
   npm run setup  # Installs Playwright browsers
   ```

### Running Tests

**Interactive Mode:**
```bash
cd tests
node test_router.js
```

**Command Line:**
```bash
# Run specific test types
npm run test:unit        # Rails RSpec tests
npm run test:api         # Direct API tests
npm run test:api-svelte  # Frontend-backend integration
npm run test:e2e         # End-to-end tests
npm run test:all         # All test suites

# Or using the router directly
node test_router.js unit
node test_router.js api
node test_router.js api-svelte
node test_router.js e2e
node test_router.js all
```

## Directory Structure

```
tests/
├── README.md                    # This file
├── test_router.js              # Main test router
├── test_config.json            # Test configuration
├── package.json                # Dependencies
│
├── unit/                       # Rails Unit Tests
│   ├── README.md              
│   └── run_rails_tests.js     # Rails test runner
│
├── api/                        # Direct API Tests
│   ├── README.md
│   ├── generate_tests.js      # Generate tests from collection.json
│   ├── run_all.js            # Generated test runner
│   ├── test_helper.js        # Generated helper functions
│   ├── environment.js        # Generated environment config
│   └── *_test.js             # Generated test files
│
├── api_svelte/                 # Integration Tests
│   ├── README.md
│   ├── integration_tests.js   # Main integration tests
│   └── run_all.js            # Integration test runner
│
├── e2e/                        # End-to-End Tests
│   ├── README.md
│   ├── playwright.config.js   # Playwright configuration
│   ├── global-setup.js       # Test environment setup
│   ├── global-teardown.js    # Test cleanup
│   └── tests/                # E2E test files
│       └── sample.e2e.js     # Sample E2E test
│
├── shared/                     # Shared Utilities
│   └── postman_parser.js     # Postman collection parser
│
└── reports/                    # Test Reports
    ├── rspec_report.html      # RSpec HTML report
    ├── api_test_results.json  # API test results
    ├── integration_report.json # Integration test results
    └── e2e-html-report/       # Playwright HTML reports
```

## Test Types Explained

### 1. Unit Tests 🔧
- **Purpose**: Test Rails backend components in isolation
- **Technology**: RSpec
- **Location**: Uses existing `spec/` directory
- **What it tests**: Models, controllers, services, jobs, etc.

**Features:**
- Interactive test category selection
- Coverage reporting with SimpleCov
- Failed test re-running
- Parallel execution support

### 2. API Tests 🌐
- **Purpose**: Test API endpoints directly (no frontend)
- **Technology**: Mocha + Axios + Generated from Postman
- **Location**: `tests/api/`
- **What it tests**: HTTP endpoints, authentication, JSON responses

**Features:**
- Auto-generated from `collection.json`
- Authentication handling
- JSON:API format validation
- Automatic retry on failures
- Performance monitoring

### 3. API-Svelte Tests 🔄
- **Purpose**: Test frontend-backend communication
- **Technology**: Custom integration framework
- **Location**: `tests/api_svelte/`
- **What it tests**: CORS, data flow, error handling, authentication flow

**Features:**
- CORS configuration validation
- Authentication flow testing
- Data serialization/deserialization
- Error response handling
- Performance characteristics

### 4. End-to-End Tests 🎭
- **Purpose**: Test complete user workflows
- **Technology**: Playwright
- **Location**: `tests/e2e/`
- **What it tests**: User interactions, complete workflows, browser compatibility

**Features:**
- Multi-browser testing (Chrome, Firefox, Safari)
- Mobile responsiveness testing
- Visual regression testing
- Accessibility testing
- Performance monitoring

## Configuration

Edit `test_config.json` to customize:

```json
{
  "rails": {
    "command": "bundle exec rspec",
    "coverage": true,
    "parallel": false
  },
  "api": {
    "baseUrl": "http://localhost:3000",
    "timeout": 30000,
    "auth": {
      "tokenEndpoint": "/auth/login",
      "testCredentials": {
        "email": "test@procstudio.com.br",
        "password": "testpass123"
      }
    }
  },
  "frontend": {
    "baseUrl": "http://localhost:5173"
  },
  "e2e": {
    "browser": "chromium",
    "headless": true,
    "screenshots": true
  }
}
```

## Setting Up API Tests

The API tests are automatically generated from your `collection.json` file:

1. **Export** your Postman collection to `collection.json` in the project root
2. **Generate** tests:
   ```bash
   cd tests/api
   node generate_tests.js
   ```
3. **Run** tests:
   ```bash
   node run_all.js
   ```

## Setting Up E2E Tests

1. **Install** Playwright browsers:
   ```bash
   npx playwright install
   ```

2. **Create** test users (automatic during first run):
   ```bash
   cd tests/e2e
   node global-setup.js
   ```

3. **Run** E2E tests:
   ```bash
   npx playwright test
   ```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: '**/package-lock.json'
          
      - name: Setup Database
        run: |
          bundle exec rails db:create db:migrate
          RAILS_ENV=test bundle exec rails db:create db:migrate
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          
      - name: Start Rails Server
        run: bundle exec rails server -d
        
      - name: Start Frontend
        run: |
          cd frontend
          npm install
          npm run build
          npm run dev &
          
      - name: Run Test Suite
        run: |
          cd tests
          npm install
          npm run setup
          npm run test:all
        env:
          CI: true
          BASE_URL: http://localhost:3000
          FRONTEND_URL: http://localhost:5173
```

## Test Reports

All tests generate comprehensive reports:

- **HTML Reports**: Visual test results with screenshots/videos
- **JSON Reports**: Machine-readable results for CI/CD
- **JUnit XML**: For integration with CI tools
- **Coverage Reports**: Code coverage metrics

Reports are saved to `tests/reports/` directory.

## Debugging Tests

### Failed Tests
```bash
# Run specific test file
npx mocha tests/api/specific_test.js

# Run with debug output
DEBUG=* npm run test:api

# Re-run only failed tests
node test_router.js unit failed
```

### Browser Tests
```bash
# Run in headed mode (see browser)
npx playwright test --headed

# Debug mode with browser developer tools
npx playwright test --debug

# Run specific browser
npx playwright test --project=chromium
```

## Common Issues & Solutions

### 1. Authentication Failures
- Check test credentials in `test_config.json`
- Ensure Rails server is running
- Verify authentication endpoints are correct

### 2. Server Connection Errors
- Confirm Rails server is running on port 3000
- Confirm Svelte server is running on port 5173
- Check firewall/network settings

### 3. Database Issues
- Reset test database: `RAILS_ENV=test bundle exec rails db:reset`
- Check database permissions
- Ensure test environment is configured

### 4. Browser Test Failures
- Install browser dependencies: `npx playwright install-deps`
- Check if display server is available (Linux)
- Review screenshots/videos in test results

## Best Practices

### Writing Tests
1. **Descriptive Names**: Use clear, descriptive test names
2. **Independent Tests**: Tests should not depend on each other
3. **Clean State**: Reset state between tests
4. **Mock External Services**: Don't rely on external APIs
5. **Test Data**: Use factories or fixtures for consistent data

### Organizing Tests
1. **Group Related Tests**: Use describe blocks effectively
2. **Shared Setup**: Use before/beforeEach hooks
3. **Test Categories**: Organize tests by feature/component
4. **Documentation**: Document complex test scenarios

### Performance
1. **Parallel Execution**: Use parallel test runners when possible
2. **Selective Testing**: Run only relevant tests during development
3. **Fast Feedback**: Prioritize quick tests for CI
4. **Resource Cleanup**: Clean up resources after tests

## Contributing

When adding new tests:

1. **Choose the Right Type**:
   - Unit tests for business logic
   - API tests for endpoint behavior
   - Integration tests for data flow
   - E2E tests for user workflows

2. **Follow Conventions**:
   - Use existing helper functions
   - Follow naming patterns
   - Add proper documentation

3. **Update Configuration**:
   - Add new test credentials if needed
   - Update test data fixtures
   - Document any new dependencies

## Support

- **Test Issues**: Check server logs and test output
- **Configuration**: Review `test_config.json` settings
- **Environment**: Ensure all prerequisites are met
- **Documentation**: Each test type has detailed README files

## Changelog

- **v1.0.0**: Initial test router implementation
- **v1.1.0**: Added API test generation from Postman collections
- **v1.2.0**: Added integration testing framework
- **v1.3.0**: Added comprehensive E2E testing with Playwright

---

**Happy Testing! 🎉**

For detailed information about specific test types, see the README files in each subdirectory.