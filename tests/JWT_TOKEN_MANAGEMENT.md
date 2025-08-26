# JWT Token Management System

## Overview

Yes, the test router **does save and manage JWT tokens** after user login! Here's a comprehensive overview of how JWT token handling works in our test system.

## 🔐 Token Management Features

### 1. **Automatic Token Persistence**
- Tokens are automatically saved to `.tokens.json` file
- Persisted across test runs and system restarts
- Multiple user types supported simultaneously
- In-memory caching for performance

### 2. **Smart Token Lifecycle**
- **Auto-Refresh**: Tokens are refreshed before expiration
- **Expiry Detection**: JWT payload is parsed to detect expiration
- **Cache Management**: Invalid/expired tokens are automatically cleared
- **Retry Logic**: Failed requests with expired tokens trigger refresh

### 3. **Multi-User Support**
- **Default User**: From test configuration
- **Admin User**: Full system access
- **Regular User**: Standard permissions
- **Lawyer User**: Legal system access
- **Custom Users**: Support for any user type

## 🔧 Implementation Details

### Core Components

#### 1. **TokenManager Class** (`shared/token_manager.js`)
```javascript
// Auto-authenticate and get token
const token = await tokenManager.authenticate('admin');

// Make authenticated requests
const response = await tokenManager.authenticatedRequest('GET', '/users');

// Get token info
const tokenInfo = tokenManager.getTokenInfo('admin');
```

#### 2. **API Test Helper** (`api/test_helper.js`)
```javascript
// Simple authentication
await apiHelper.authenticate('user');

// Authenticated request with automatic token handling
const response = await apiHelper.request('GET', '/cases', null, {
  userType: 'lawyer'
});
```

#### 3. **Test Integration**
All generated API tests automatically:
- Authenticate before running
- Use cached tokens when valid
- Refresh tokens when needed
- Handle authentication failures gracefully

## 📁 Token Storage

### Persistent Storage
```json
// .tokens.json (automatically created)
{
  "default_token": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userType": "default",
    "expiresAt": 1703123456789,
    "obtainedAt": 1703120456789,
    "credentials": {
      "email": "test@procstudio.com.br",
      "password": "testpass123"
    }
  },
  "admin_token": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userType": "admin",
    "expiresAt": 1703125456789,
    "obtainedAt": 1703121456789
  }
}
```

### In-Memory Cache
- Fast access during test execution
- Automatic cleanup of expired tokens
- Thread-safe token management

## 🚀 Usage Examples

### Basic Authentication
```javascript
// In any test file
const { tokenManager } = require('../shared/token_manager');

// Get token for default user
const token = await tokenManager.authenticate();

// Get token for specific user type
const adminToken = await tokenManager.authenticate('admin');
```

### Authenticated API Requests
```javascript
// Direct API call with authentication
const response = await tokenManager.authenticatedRequest(
  'POST', 
  '/cases', 
  { title: 'New Case' },
  { userType: 'lawyer' }
);

// Using API helper
const { apiHelper } = require('./test_helper');
const response = await apiHelper.request('GET', '/users', null, {
  userType: 'admin'
});
```

### Token Management
```javascript
// Check token status
const tokenInfo = tokenManager.getTokenInfo('admin');
console.log(tokenInfo);
// Output:
// {
//   status: 'valid',
//   userType: 'admin',
//   obtainedAt: '2023-12-20T10:30:00.000Z',
//   expiresAt: '2023-12-20T11:30:00.000Z',
//   needsRefresh: false
// }

// Clear tokens
tokenManager.clearTokensForUser('admin');  // Clear specific user
tokenManager.clearAllTokens();             // Clear all tokens
```

## ⚙️ Configuration

### Test Config (`test_config.json`)
```json
{
  "api": {
    "baseUrl": "http://localhost:3000",
    "auth": {
      "type": "bearer",
      "tokenEndpoint": "/auth/login",
      "refreshEndpoint": "/auth/refresh",
      "validateEndpoint": "/auth/validate",
      "tokenStorage": true,
      "autoRefresh": true,
      "refreshThreshold": 300000,
      "testCredentials": {
        "email": "test@procstudio.com.br",
        "password": "testpass123"
      },
      "testUsers": {
        "admin": {
          "email": "admin@e2etest.procstudio.com",
          "password": "E2ETestPass123!"
        },
        "user": {
          "email": "user@e2etest.procstudio.com",
          "password": "E2ETestPass123!"
        },
        "lawyer": {
          "email": "lawyer@e2etest.procstudio.com",
          "password": "E2ETestPass123!"
        }
      }
    }
  }
}
```

### Environment Variables
```bash
# Override base URL
BASE_URL=http://localhost:3000

# Override test credentials
TEST_ADMIN_EMAIL=admin@mycompany.com
TEST_ADMIN_PASSWORD=MySecretPassword

TEST_USER_EMAIL=user@mycompany.com
TEST_USER_PASSWORD=UserPassword
```

## 🔄 Token Lifecycle

### 1. **Initial Authentication**
```
User Request → Check Cache → No Token Found → Authenticate with API → 
Parse JWT → Store Token & Expiry → Return Token
```

### 2. **Cached Token Usage**
```
User Request → Check Cache → Valid Token Found → Return Cached Token
```

### 3. **Automatic Refresh**
```
User Request → Check Cache → Token Near Expiry → Refresh Token → 
Update Cache → Return New Token
```

### 4. **Expired Token Handling**
```
API Request → 401 Unauthorized → Clear Cache → Re-authenticate → 
Retry Request → Return Response
```

## 🧪 Testing Token Management

### Run Token Tests
```bash
# Test token management system
cd tests
node shared/token_test.js

# Interactive token testing
node shared/token_test.js --interactive

# Test specific aspects
node -e "
const { tokenManager } = require('./shared/token_manager');
tokenManager.authenticate('admin').then(token => {
  console.log('Token:', token.substring(0, 20) + '...');
  console.log('Info:', tokenManager.getTokenInfo('admin'));
});
"
```

### Integration with Test Router
```bash
# All tests use automatic token management
node test_router.js api          # API tests with JWT
node test_router.js api-svelte   # Integration tests with JWT
node test_router.js e2e          # E2E tests with authentication
```

## 🔍 Debugging Token Issues

### Token Information
```javascript
// Check all cached tokens
const allTokens = tokenManager.getAllTokens();
console.log('All tokens:', JSON.stringify(allTokens, null, 2));

// Check specific token
const adminInfo = tokenManager.getTokenInfo('admin');
console.log('Admin token:', adminInfo);
```

### Token Validation
```javascript
// Validate token with server
const isValid = await tokenManager.validateTokenWithServer('admin');
console.log('Token valid on server:', isValid);

// Setup test authentication
const results = await tokenManager.setupTestTokens();
console.log('Setup results:', results);
```

### Common Issues & Solutions

#### ❌ **"Authentication failed"**
- Check credentials in `test_config.json`
- Verify Rails server is running
- Confirm authentication endpoint is correct

#### ❌ **"Token expired"**
- Tokens are auto-refreshed, but check server time sync
- Verify JWT expiration is reasonable (not too short)

#### ❌ **"No token found"**
- Check if initial authentication succeeded
- Verify token storage permissions
- Clear cache and re-authenticate: `tokenManager.clearAllTokens()`

## 🚀 Benefits

### For Developers
- **Zero Configuration**: Works out of the box
- **Automatic Management**: No manual token handling
- **Multi-User Testing**: Test different user roles easily
- **Performance**: Cached tokens avoid repeated authentication

### For Tests
- **Reliability**: Automatic refresh prevents test failures
- **Speed**: Cached tokens make tests faster
- **Isolation**: Each user type has separate tokens
- **Debugging**: Rich token information for troubleshooting

### For CI/CD
- **Stateless**: Each test run starts fresh
- **Parallel**: Different test processes don't interfere
- **Robust**: Handles network issues and token expiry
- **Configurable**: Environment-specific settings

## 📊 Token Usage Across Test Types

| Test Type | Token Usage | User Types | Persistence |
|-----------|-------------|------------|-------------|
| **Unit Tests** | ❌ Not needed | N/A | N/A |
| **API Tests** | ✅ Full support | All types | File + Memory |
| **Integration Tests** | ✅ Full support | All types | File + Memory |
| **E2E Tests** | ✅ Browser storage | All types | Storage states |

## 🎯 Summary

**Yes, JWT tokens are fully managed!** The system:

✅ **Saves tokens** after successful login
✅ **Persists tokens** across test runs
✅ **Caches tokens** for performance
✅ **Refreshes tokens** automatically
✅ **Supports multiple users** simultaneously
✅ **Handles token expiry** gracefully
✅ **Provides debugging tools** for token issues
✅ **Works across all test types** seamlessly

The JWT token management is production-ready and handles all the complexity of authentication, so your tests can focus on testing functionality rather than managing tokens! 🚀