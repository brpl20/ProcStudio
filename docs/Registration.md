[Back](../README.md)

# ProcStudio - Registration System Documentation

## Overview

The ProcStudio API implements two distinct user registration systems. Following [auth](Auth.md) authentication rules, user registration enables creating accounts in two ways: public registration for new users and team member registration for existing authenticated users.

## Registration Types

### 1. Public Registration (First-time Users)
- Open to anyone without authentication
- Creates both User and Team automatically
- Optional OAB integration for lawyers
- Generates unique subdomain for the team

### 2. Team Member Registration (Authenticated Users)
- Requires existing user authentication
- Creates new User + UserProfile within existing team
- Maintains team association and scoping

## Registration Endpoints

### Public User Registration

#### Create New User Account
- **Endpoint**: `POST /api/v1/public/user_registration`
- **Controller**: `Api::V1::Public::UserRegistrationController#create`
- **Authentication**: None required (public endpoint)
- **Parameters**:
  ```json
  {
    "user": {
      "email": "lawyer@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "oab": "PR_54159"  // Optional - Brazilian Bar Association number
    }
  }
  ```

#### Successful Response:
```json
{
  "success": true,
  "message": "User and team created successfully",
  "data": {
    "id": 123,
    "email": "lawyer@example.com",
    "oab": "PR_54159",
    "team": {
      "id": 456,
      "name": "Escritório João Silva",
      "subdomain": "joao-silva-escritorio"
    },
    "profile_created": true,
    "profile": {
      "name": "João",
      "last_name": "Silva",
      "role": "lawyer"
    }
  }
}
```

#### Error Response:
```json
{
  "success": false,
  "message": "Email já está em uso",
  "errors": ["Email já está em uso"]
}
```

### Team Member Registration (User Profiles)

#### Create Team Member
- **Endpoint**: `POST /api/v1/user_profiles`
- **Controller**: `Api::V1::UserProfilesController#create`
- **Authentication**: Required (JWT token in Authorization header)
- **Headers**: `Authorization: Bearer <token>`
- **Parameters**:
  ```json
  {
    "user_profile": {
      "name": "Maria",
      "last_name": "Santos",
      "role": "paralegal",
      "oab": "",
      "user_attributes": {
        "email": "maria@example.com",
        "password": "password123",
        "password_confirmation": "password123"
      },
      "phones_attributes": [
        {
          "phone_number": "11999999999"
        }
      ],
      "addresses_attributes": [
        {
          "street": "Rua das Flores",
          "number": "123",
          "neighborhood": "Centro",
          "city": "São Paulo",
          "state": "SP",
          "zip_code": "01000-000"
        }
      ]
    }
  }
  ```

#### Successful Response:
```json
{
  "success": true,
  "message": "Perfil de usuário criado com sucesso",
  "data": {
    "id": "789",
    "type": "user_profile",
    "attributes": {
      "name": "Maria",
      "last_name": "Santos",
      "role": "paralegal",
      "status": "active",
      "access_email": "maria@example.com",
      "user_id": 124,
      "office_id": null,
      "gender": null,
      "oab": null,
      "cpf": null,
      "rg": null,
      "nationality": null,
      "civil_status": null,
      "birth": null
    }
  }
}
```

## Registration Process Flow

### Public Registration Flow

```
1. Client sends registration request to /api/v1/public/user_registration
2. System validates email uniqueness and password strength
3. Creates Team with auto-generated name and subdomain
4. Creates User associated with the new Team
5. If OAB provided:
   a. Fetches lawyer data from OAB API
   b. Creates UserProfile with lawyer information
   c. Attaches avatar from profile picture URL
   d. Creates addresses and phones from OAB data
6. Returns user data with team and profile information
```

### Team Member Registration Flow

```
1. Authenticated user sends request to /api/v1/user_profiles
2. System validates current user permissions
3. Creates new User within current team
4. Creates UserProfile with provided data
5. Associates nested attributes (phones, addresses)
6. Returns complete profile data via serializer
```

## Data Models

Registration creates and manages relationships between:

- **User**: Core authentication record with email/password (see [Auth.md](Auth.md) for details)
- **Team**: Organization/law firm container  
- **UserProfile**: Extended user information and role assignment
- **Polymorphic Associations**: Addresses and phones linked to profiles

### UserProfile Roles

- `lawyer` - Licensed lawyer (requires OAB)
- `paralegal` - Legal assistant  
- `trainee` - Law student/intern
- `secretary` - Administrative assistant
- `counter` - Accountant
- `representant` - Legal representative

## OAB Integration

### Automatic Profile Creation

When registering with an OAB (Brazilian Bar Association) number, the system:

1. **Validates OAB**: Calls external Legal Data API to verify the OAB number
2. **Fetches Lawyer Data**: Retrieves name, registration info, and profile picture
3. **Creates UserProfile**: Automatically populates profile with lawyer information
4. **Downloads Avatar**: Attaches profile picture from external URL to Active Storage
5. **Creates Contact Info**: Adds addresses and phones from OAB data if available

### Example OAB Data Processing

```ruby
# From user_registration_controller.rb:105-147
def create_profile_from_oab(user)
  oab_service = LegalData::LegalDataService.new
  lawyer_data = oab_service.find_lawyer(user.oab)
  
  user_profile = user.create_user_profile!(
    name: lawyer_data[:name],
    last_name: lawyer_data[:last_name],
    oab: lawyer_data[:oab],
    role: 'lawyer',
    status: 'active',
    gender: lawyer_data[:gender]
  )
  
  # Create address from OAB data
  create_address_from_data(user_profile, lawyer_data) if has_address_data?(lawyer_data)
  
  # Create phone from OAB data  
  create_phone_from_data(user_profile, lawyer_data) if lawyer_data[:phone].present?
  
  # Attach avatar from profile picture URL
  if lawyer_data[:profile_picture_url].present?
    avatar_service = LegalData::AvatarAttachmentService.new
    avatar_service.attach_from_url(user_profile, lawyer_data[:profile_picture_url])
  end
end
```

## Team Creation and Subdomain Generation

### Automatic Team Creation

For public registrations, the system automatically creates teams:

1. **Subdomain Generation**: Uses `TeamSubdomainGenerator.generate()` based on:
   - Lawyer name (if OAB provided)
   - Email prefix (if no lawyer name)
   - Ensures uniqueness across all teams

2. **Team Naming**: Generates descriptive names:
   - "Escritório [Lawyer Name]" for lawyers
   - "Escritório [Email Prefix]" for others
   - "Meu Escritório" as fallback

3. **Team Settings**: Marks as auto-created for tracking purposes

### Example Team Creation

```ruby
# Generated team data
{
  name: "Escritório João Silva",
  subdomain: "joao-silva-escritorio",
  settings: { auto_created: true }
}
```

## Profile Completion System

### Complete Profile Endpoint
- **Endpoint**: `POST /api/v1/user_profiles/complete_profile`
- **Controller**: `Api::V1::UserProfilesController#complete_profile`
- **Purpose**: Allows users to complete missing profile information
- **Authentication**: Required

#### Required Fields for Profile Completion:
- **Basic**: name, last_name, cpf, rg, role, gender, civil_status, nationality, birth
- **Lawyers**: oab (additional requirement)
- **Contact**: at least one phone and address

#### Request Example:
```json
{
  "user_profile": {
    "name": "João",
    "last_name": "Silva",
    "cpf": "12345678901",
    "rg": "123456789",
    "gender": "male",
    "civil_status": "single",
    "nationality": "brazilian",
    "birth": "1990-01-01",
    "phones_attributes": [
      {
        "phone_number": "11999999999"
      }
    ],
    "addresses_attributes": [
      {
        "street": "Rua das Flores",
        "number": "123",
        "neighborhood": "Centro",
        "city": "São Paulo",
        "state": "SP",
        "zip_code": "01000-000"
      }
    ]
  }
}
```

## Additional Endpoints

### User Profile Management

#### List User Profiles
- **Endpoint**: `GET /api/v1/user_profiles`
- **Filters**: Team-scoped (super admins see all)

#### Show User Profile
- **Endpoint**: `GET /api/v1/user_profiles/:id`
- **Returns**: Complete profile data with relationships

#### Update User Profile
- **Endpoint**: `PUT/PATCH /api/v1/user_profiles/:id`
- **Supports**: Nested attributes for phones and addresses

#### Soft Delete/Restore User Profile
- **Delete**: `DELETE /api/v1/user_profiles/:id`
- **Restore**: `POST /api/v1/user_profiles/:id/restore`

## Error Handling

### Common Registration Errors

1. **Email Already Exists**
   ```json
   {
     "success": false,
     "message": "Email já está em uso",
     "errors": ["Email já está em uso"]
   }
   ```

2. **Password Confirmation Mismatch**
   ```json
   {
     "success": false,
     "message": "Password confirmation doesn't match Password",
     "errors": ["Password confirmation doesn't match Password"]
   }
   ```

3. **Invalid OAB Number**
   ```json
   {
     "success": false,
     "message": "OAB inválida",
     "errors": ["OAB inválida"]
   }
   ```

4. **Profile Incomplete**
   ```json
   {
     "success": false,
     "message": "Name can't be blank",
     "errors": ["Name can't be blank", "Role can't be blank"]
   }
   ```

### HTTP Status Codes
- **201 Created**: Successful registration
- **422 Unprocessable Entity**: Validation errors
- **401 Unauthorized**: Authentication required (team member registration)
- **500 Internal Server Error**: System errors

## Security Considerations

Registration follows the same security patterns detailed in [Auth.md](Auth.md), with additional considerations:

- **Team Isolation**: New user profiles are automatically scoped to current team
- **Role Validation**: User roles are validated against allowed enum values
- **Nested Attributes**: Strong parameter filtering for addresses and phones

## Testing Registration

### Public Registration
```bash
curl -X POST http://localhost:3000/api/v1/public/user_registration \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com", 
      "password": "password123",
      "password_confirmation": "password123",
      "oab": "SP_123456"
    }
  }'
```

### Team Member Registration  
```bash
curl -X POST http://localhost:3000/api/v1/user_profiles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "user_profile": {
      "name": "Team Member",
      "role": "paralegal", 
      "user_attributes": {
        "email": "member@example.com",
        "password": "password123", 
        "password_confirmation": "password123"
      }
    }
  }'
```
