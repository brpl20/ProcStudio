# User and UserProfile API Tests

This directory contains comprehensive API tests for the User and UserProfile functionality in the ProcStudio API.

## Overview

The tests are designed to validate both public user registration endpoints and private user management functionality, including profile completion scenarios and nested attribute handling.

## Test Files

### 1. `users_test.js`
Tests the core user functionality including:

#### Public Registration Tests
- **User Registration - Success with working OAB**: Tests successful registration with valid OAB that returns pre-filled profile data
- **User Registration - OAB not working**: Tests registration with invalid OAB that requires manual profile completion
- **User Registration - Email must be unique**: Validates email uniqueness constraints
- **User Registration - OAB must be filled**: Ensures OAB requirement validation

#### Private User Management Tests
- **Create user with nested attributes**: Tests creation of users with complete profile data including addresses, phones, and bank accounts
- **List all users**: Validates user listing with proper scope restrictions
- **Get specific user**: Tests individual user retrieval
- **Update user profile**: Tests user profile updates
- **Delete user profile**: Tests user deletion functionality
- **Test unauthorized access**: Validates cross-user access restrictions

### 2. `user_tests.js`
Tests focused specifically on the User model and authentication:

#### User Authentication Tests
- **User Login - Success**: Tests successful login with valid credentials
- **User Login - Invalid credentials**: Tests login failure with wrong password
- **User Login - Missing email**: Tests validation of required email field
- **User Logout - Success**: Tests successful logout functionality

#### User Management Tests
- **Create new user**: Tests user creation with email and password
- **List all users**: Tests user listing functionality
- **Get specific user**: Tests individual user retrieval
- **Update user**: Tests user information updates
- **Delete user**: Tests user deletion functionality
- **Test unauthorized access**: Tests cross-user access restrictions

#### User Validation Tests
- **Email uniqueness validation**: Tests duplicate email prevention
- **Password confirmation validation**: Tests password/confirmation matching
- **Required fields validation**: Tests mandatory field validation
- **Invalid email format validation**: Tests email format validation

#### User Password Management Tests
- **Password change**: Tests password update functionality
- **Password reset request**: Tests password reset flow initiation

#### User Session Management Tests
- **Current user info**: Tests authenticated user information retrieval
- **Token validation**: Tests JWT token validation
- **Invalid token handling**: Tests rejection of invalid tokens

### 3. `user_profiles_test.js`
Tests user profile management and completion scenarios:

#### Profile Completion Tests
- **Login with incomplete profile**: Tests login flow for users with incomplete profiles
- **Complete profile with all required fields**: Tests profile completion with all mandatory data

#### Profile Management Tests
- **Create complete profile**: Tests creation of complete user profiles with nested attributes
- **List all profiles**: Validates profile listing functionality
- **Get specific profile**: Tests individual profile retrieval
- **Update profile with nested attributes**: Tests profile updates including addresses and phones
- **CPF validation**: Tests Brazilian CPF number validation
- **Delete profile**: Tests profile deletion
- **Scope validation**: Tests cross-user access restrictions

#### Profile Validation Tests
- **Required fields validation**: Tests mandatory field validation
- **Email uniqueness in nested attributes**: Tests email uniqueness in user_attributes

## Test Data Patterns

### Working OAB Response Example
```json
{
    "success": true,
    "message": "User and team created successfully",
    "data": {
        "id": 29,
        "email": "u22@gmail.com",
        "oab": "PR_54161",
        "team": {
            "id": 6,
            "name": "Escritório Dayeni Cristina De Oliveira",
            "subdomain": "dayeni-cristina-de-oliveira"
        },
        "profile_created": true,
        "profile": {
            "name": "Dayeni",
            "last_name": "Cristina De Oliveira",
            "role": "lawyer"
        }
    }
}
```

### Non-working OAB Response Example
```json
{
    "success": true,
    "message": "Perfil incompleto. Por favor complete as informações necessárias.",
    "data": {
        "token": "eyJhbGciOiJIUzI1NiJ9...",
        "needs_profile_completion": true,
        "missing_fields": [
            "name", "last_name", "cpf", "rg", "role", "gender",
            "civil_status", "nationality", "birth", "phone", "address"
        ],
        "oab": "PR_5llll4161",
        "message": "Perfil incompleto. Por favor complete as informações necessárias."
    }
}
```

### Complete User Profile Creation
```json
{
    "user_profile": {
        "role": "lawyer",
        "status": "active",
        "name": "John",
        "last_name": "Doe",
        "gender": "male",
        "oab": "PR_54159",
        "rg": "50.871.886-7",
        "cpf": "688.481.730-55",
        "nationality": "foreigner",
        "civil_status": "single",
        "birth": "1980-03-30",
        "mother_name": "Lara Doe",
        "user_attributes": {
            "email": "u199@gmail.com",
            "password": "123456",
            "password_confirmation": "123456"
        },
        "addresses_attributes": [...],
        "phones_attributes": [...],
        "bank_accounts_attributes": [...]
    }
}
```

## Running the Tests

### Prerequisites
1. API server running on `http://localhost:3000`
2. Test users configured:
   - `u1@gmail.com` / `123456`
   - `u2@gmail.com` / `123456`
3. Node.js >= 16.0.0
4. Required dependencies installed

### Run Individual Test Files
```bash
# Run user management tests
npx mocha api/Users_UsersProfile/users_test.js --timeout 30000

# Run user model tests
npx mocha api/Users_UsersProfile/user_tests.js --timeout 30000

# Run user profile tests
npx mocha api/Users_UsersProfile/user_profiles_test.js --timeout 30000
```

### Run All User Tests
```bash
# Using the provided test runner
node run_user_tests.js

# Or run both files with mocha
npx mocha api/Users_UsersProfile/*.js --timeout 30000
```

### Run with Specific Reporter
```bash
npx mocha api/Users_UsersProfile/*.js --reporter spec --timeout 30000
```

## Dependencies

### Test Framework
- **Mocha**: Test framework
- **Chai**: Assertion library
- **Axios**: HTTP client for API requests

### Test Utilities
- **AuthHelper**: Handles authentication for API tests
- **CPFGenerator**: Generates valid Brazilian CPF numbers for testing
- **CNPJGenerator**: Generates valid Brazilian CNPJ numbers for testing

## API Endpoints Tested

### Public Endpoints
- `POST /api/v1/public/user_registration` - User registration

### Private Endpoints (Authenticated)
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- `GET /api/v1/users/:id` - Get specific user
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user
- `GET /api/v1/user_profiles` - List user profiles
- `POST /api/v1/user_profiles` - Create user profile
- `GET /api/v1/user_profiles/:id` - Get specific user profile
- `PUT /api/v1/user_profiles/:id` - Update user profile
- `DELETE /api/v1/user_profiles/:id` - Delete user profile
- `POST /api/v1/login` - User login
- `DELETE /api/v1/logout` - User logout
- `GET /api/v1/me` - Get current user info
- `GET /api/v1/validate_token` - Validate authentication token
- `PATCH /api/v1/users/:id/change_password` - Change user password
- `POST /api/v1/password/reset` - Request password reset

## Security Validations

The tests include security validations to ensure:
- Users can only access their own profiles and data
- Email uniqueness is enforced
- Authentication is required for private endpoints
- Cross-user access attempts are properly blocked

## Test Data Cleanup

The tests automatically clean up created test data to avoid polluting the database:
- Created users and profiles are deleted after tests
- Unique identifiers (timestamps) are used to avoid conflicts
- Test data uses recognizable patterns for easy identification

## Troubleshooting

### Common Issues

1. **Authentication Failures**: Ensure test users `u1@gmail.com` and `u2@gmail.com` exist with password `123456`
2. **Timeout Errors**: Increase timeout with `--timeout 60000` if server responses are slow
3. **Connection Errors**: Verify API server is running on `http://localhost:3000`
4. **Missing Dependencies**: Run `npm install` in the tests directory

### Debug Mode
Add verbose logging by setting environment variable:
```bash
DEBUG=test* node run_user_tests.js
```

## Contributing

When adding new tests:
1. Follow the existing naming conventions
2. Include proper cleanup of test data
3. Add security validation tests for new endpoints
4. Update this README with new test descriptions
5. Use the provided helper utilities (CPF/CNPJ generators, AuthHelper)

## Notes

- Tests use real API endpoints and require a running server
- CPF and CNPJ numbers are generated with valid check digits
- OAB validation tests use predefined valid/invalid OAB numbers
- Profile completion scenarios test the complete user onboarding flow
- All tests include proper error handling and meaningful assertions