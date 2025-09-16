# API Testing Guidelines

## API Testing Structure
- Use JS Mocha for API testing
- Test all HTTP verbs (GET, POST, PUT, PATCH, DELETE)
- Create one file for each verb them centralize everything into a facade pattern design
- Break down Delete into Soft Delete and Hard delete
- Create helpers to track changes in backend:
    - For example Customer tests and changes in: Models, Controllers and Serializers
    - Console log warning if changes ocur (compare date from last update of the test and the last update of the models)
- Verify routes
- Verify response status codes
- Check response body structure and content
- Create fake and random data
- Test authentication and authorization
- Validate error responses and edge cases
- API tests should verify the complete request-response cycle, including authentication, validation, data transformation, and error handling.

## API Test File Organization

### Example Directory Structure
```
api/
├── ProfileCustomers/
│   ├── config.js              # Configuration
│   ├── create.js              # POST tests
│   ├── index.js               # GET index tests
│   ├── read.js                # GET read tests
│   ├── update.js              # PUT/PATCH tests
│   ├── delete-soft.js         # Soft delete tests
│   ├── delete-hard.js         # Hard delete tests
│   ├── custom-{name}.js       # Custom Route
│   ├── custom-{name}.js       # Custom Route
│   ├── tests.js               # Test runner facade
│   └── data.js                # Test data generators
│   └── (similar structure)    # todo...
├── config.js                  # Global API test configuration
└── auth_helper.js             # Authentication helpers
```
