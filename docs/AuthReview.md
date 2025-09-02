[Back](../README.md)

# ProcStudio API - Authentication System Documentation

## Overview

The ProcStudio API implements a comprehensive authentication system based on **JWT (JSON Web Tokens)** with **Devise** for user management. The system supports two distinct user types: **Users** (internal system users/administrators) and **Customers** (external clients), each with their own authentication flows and access controls.

## Technology Stack

- **Devise** - User authentication and management
- **JWT** - Stateless token-based authentication
- **BCrypt** - Password hashing (via Devise)
- **Pundit** - Authorization policies

## Architecture Overview

### 1. User Types

#### Users (Internal)
- System administrators and staff members
- Associated with teams (`belongs_to :team`)
- Has profiles with roles and permissions
- Stored in `users` table

#### Customers (External)
- External clients using the system
- Can belong to multiple teams via `team_customers`
- Has profile information in `profile_customers`
- Stored in `customers` table
- Supports email confirmation workflow

### 2. Authentication Flow

```
Client → API Request with Credentials → Authentication Controller
         ↓
         Validates Credentials (Devise)
         ↓
         Generates JWT Token
         ↓
         Returns Token to Client → Client stores token
         ↓
         Subsequent requests include token in Authorization header
```

## Authentication Endpoints

### User Authentication

#### Login
- **Endpoint**: `POST /api/v1/login`
- **Controller**: `Api::V1::AuthController#authenticate`
- **Parameters**:
  ```json
  {
    "auth": {
      "email": "user@example.com",
      "password": "password123"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Login realizado com sucesso",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiJ9...",
      "needs_profile_completion": false,
      "role": "admin",
      "name": "John",
      "last_name": "Doe"
    }
  }
  ```

#### Logout
- **Endpoint**: `DELETE /api/v1/logout`
- **Controller**: `Api::V1::AuthController#destroy`
- **Headers**: `Authorization: Bearer <token>`
- **Note**: Stateless logout - frontend clears token

### Customer Authentication

#### Login (Email/Password)
- **Endpoint**: `POST /api/v1/customer/login`
- **Controller**: `Api::V1::Customer::AuthController#authenticate`
- **Parameters**:
  ```json
  {
    "auth": {
      "email": "customer@example.com",
      "password": "password123"
    }
  }
  ```

#### Login (Google OAuth)
- **Endpoint**: `POST /api/v1/customer/login`
- **Parameters**:
  ```json
  {
    "provider": "google",
    "accessToken": "google_access_token"
  }
  ```

#### Email Confirmation
- **Endpoint**: `GET /api/v1/customer/confirm?confirmation_token=<token>`
- **Purpose**: Confirms customer email address

#### Password Reset Request
- **Endpoint**: `POST /api/v1/customer/password`
- **Parameters**:
  ```json
  {
    "customer": {
      "email": "customer@example.com"
    }
  }
  ```

#### Password Update
- **Endpoints**:
  - `PUT /api/v1/customer/password`
  - `PATCH /api/v1/customer/password`
- **Parameters**:
  ```json
  {
    "customer": {
      "password": "new_password",
      "password_confirmation": "new_password",
      "reset_password_token": "token_from_email"
    }
  }
  ```

## JWT Token Implementation

### Token Structure

Tokens are encoded using the HS256 algorithm with Rails' `secret_key_base`:

```ruby
JWT.encode(token_data, Rails.application.secret_key_base)
```

#### User Token Payload
```json
{
  "user_id": 123,
  "admin_id": 123,  // Backward compatibility
  "name": "John",
  "last_name": "Doe",
  "role": "admin",
  "exp": 1234567890  // Expiration timestamp
}
```

#### Customer Token Payload
```json
{
  "customer_id": 456,
  "exp": 1234567890  // Expiration timestamp
}
```

### Token Expiration
- Default: **24 hours** from generation
- Calculated as: `Time.now.to_i + (24 * 3600)`

### Token Validation

The `JwtAuth` concern handles token validation:

1. Extracts token from `Authorization` header
2. Decodes token with secret key
3. Verifies expiration time
4. Loads associated user/customer

## Authentication Middleware

### JwtAuth Concern (`app/controllers/concerns/jwt_auth.rb`)

Core authentication module included in controllers:

- `authenticate_user` - Validates user tokens
- `authenticate_customer` - Validates customer tokens
- `authenticate_admin` - Legacy alias for backward compatibility
- Token decoding and validation logic

### Controller Hierarchy

```
ApplicationController
├── BackofficeController (includes JwtAuth)
│   ├── before_action :authenticate_user
│   └── All admin/staff controllers
└── FrontofficeController (includes JwtAuth)
    ├── before_action :authenticate_customer
    └── All customer-facing controllers
```

## Devise Configuration

### Key Settings (`config/initializers/devise.rb`)

- **Password Length**: 6-128 characters
- **Email Format**: Standard email regex validation
- **Password Stretches**: 12 (production), 1 (test)
- **Case Insensitive Keys**: [:email]
- **Strip Whitespace Keys**: [:email]
- **Scoped Views**: Enabled
- **Reconfirmable**: Disabled
- **Reset Password Window**: 6 hours

### Devise Modules Used

#### User Model
```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable
```

#### Customer Model
```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :confirmable
```

## Profile Completion Flow

For Users, the system checks profile completeness on login:

### Required Fields
- Basic: name, last_name, cpf, rg, role, gender, civil_status, nationality, birth
- Lawyers: oab (additional requirement)
- Contact: at least one phone and address

### Response Handling
```json
{
  "needs_profile_completion": true,
  "missing_fields": ["cpf", "rg", "phone"],
  "message": "Profile incomplete"
}
```

## Authorization Layer

### Pundit Integration

After authentication, authorization is handled by Pundit policies:

- **BackofficeController**: User-based policies
- **FrontofficeController**: Customer-based policies
- Unauthorized access returns 401/403 with appropriate messages

### Team Scoping

Users are scoped to teams via `TeamScoped` concern:
- Automatic filtering of resources by team
- Multi-tenancy support
- Cross-team access prevention

## Security Considerations

### Password Security
- BCrypt hashing via Devise (cost factor: 12)
- Minimum 6 characters required
- Password confirmation on changes

### Token Security
- Stateless JWT tokens (no server-side storage)
- HTTPS required in production
- Token included in Authorization header as Bearer token
- No token refresh mechanism (requires re-authentication)

### API Security Headers
- CORS configured (`config/initializers/cors.rb`)
- Content Security Policy enabled
- Parameter filtering for sensitive data

## Error Handling

### Authentication Errors
- **401 Unauthorized**: Invalid credentials or expired token
- **403 Forbidden**: Valid authentication but insufficient permissions
- **422 Unprocessable Entity**: Validation errors (e.g., email confirmation)

### Common Error Responses
```json
{
  "success": false,
  "message": "Usuário não autorizado",
  "errors": ["Usuário não autorizado"]
}
```

## Testing Authentication

### Development Tools

The project includes an authentication testing tool:

```bash
# Authenticate test user
node ai-tools/authenticator.js auth user1

# Test API with token
node ai-tools/authenticator.js test user1 /api/v1/users
```

### Test Users
- `user1`: u1@gmail.com / 123456
- `user2`: u2@gmail.com / 123456

## Database Schema

### Users Table
```sql
- id: bigint (primary key)
- email: string (unique, required)
- encrypted_password: string
- jwt_token: string (deprecated, not used)
- reset_password_token: string
- reset_password_sent_at: datetime
- remember_created_at: datetime
- team_id: bigint (foreign key)
- status: string (active/inactive)
```

### Customers Table
```sql
- id: bigint (primary key)
- email: string (unique when not deleted)
- encrypted_password: string
- jwt_token: string (deprecated, not used)
- confirmation_token: string
- confirmed_at: datetime
- confirmation_sent_at: datetime
- reset_password_token: string
- reset_password_sent_at: datetime
- status: string (active/inactive)
```

## Future Considerations

### Potential Improvements
1. **Token Refresh**: Implement refresh tokens for better UX
2. **Rate Limiting**: Add request throttling to prevent brute force
3. **MFA**: Multi-factor authentication support
4. **Session Management**: Active session tracking and management
5. **Audit Logging**: Track authentication events
6. **Token Revocation**: Blacklist mechanism for compromised tokens

### Migration Notes
- The `jwt_token` field in database is deprecated
- Tokens are now fully stateless (not stored)
- Legacy `admin_id` maintained for backward compatibility

## Troubleshooting

### Common Issues

1. **"Usuário não autorizado"**
   - Check token expiration
   - Verify token format in Authorization header
   - Ensure secret_key_base hasn't changed

2. **Profile Incomplete Errors**
   - Complete required profile fields
   - Check `missing_fields` in response

3. **Email Confirmation Required**
   - Customer must confirm email before access
   - Check `confirmed_at` timestamp

4. **CORS Errors**
   - Verify allowed origins in CORS config
   - Check request headers match policy

## API Client Implementation Example

### JavaScript/Axios
```javascript
// Login
const response = await axios.post('/api/v1/login', {
  auth: { email, password }
});
const token = response.data.data.token;

// Authenticated Request
const config = {
  headers: { Authorization: `Bearer ${token}` }
};
await axios.get('/api/v1/users', config);
```

### Ruby/HTTParty
```ruby
# Login
response = HTTParty.post(
  "#{base_url}/api/v1/login",
  body: { auth: { email: email, password: password } }.to_json,
  headers: { 'Content-Type' => 'application/json' }
)
token = JSON.parse(response.body)['data']['token']

# Authenticated Request
HTTParty.get(
  "#{base_url}/api/v1/users",
  headers: { 'Authorization' => "Bearer #{token}" }
)
```

## Support and Contact

For authentication issues or questions:
- Check application logs for detailed error messages
- Review Devise and JWT documentation
- Contact system administrators for account issues

---

# Final Auth Checking

When checking a Ruby on Rails app for the quality of user authentication, there are several key areas to focus on. Here's what you should look for:
Security Best Practices

Password storage - Ensure passwords are properly hashed (not encrypted or stored as plaintext). Rails uses bcrypt by default with has_secure_password, which is good practice.
Password requirements - Check if the app enforces strong password policies with minimum length, complexity requirements, and rejection of commonly used passwords.
Brute force protection - Look for account lockout mechanisms or rate limiting on login attempts to prevent brute force attacks.
Session management - Verify proper session handling with secure session cookies that have appropriate expiration, HttpOnly and Secure flags.
CSRF protection - Rails has built-in CSRF protection via authenticity tokens, but verify it's actually enabled and used consistently.

Implementation Quality

Authentication gem - Check if the app uses a well-maintained gem like Devise, Clearance, or Authlogic rather than a custom implementation.
Multi-factor authentication - See if 2FA/MFA is implemented, particularly for admin or sensitive user accounts.
Secure password reset flow - Ensure the password reset process uses time-limited tokens sent to verified email addresses.
Secure account recovery - Look for robust account recovery methods that don't bypass security.
Proper authorization - Check that authentication is paired with proper authorization (using gems like CanCanCan, Pundit).

Usability Considerations

Login UX - Evaluate the login experience for usability while maintaining security.
Error messages - Check that error messages don't reveal too much information (e.g., whether a username exists).
Remember me functionality - If implemented, ensure it's done securely.
