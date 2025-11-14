# User Invitations Feature

## Overview
The User Invitations feature allows authenticated users to invite new users to join their team on the Procstudio platform. Invitees receive an email with a unique link to create their account.

## Features
- ✅ Send invitations to multiple emails (up to 50 per request)
- ✅ Secure token-based invitation system
- ✅ Email notifications via Mailjet
- ✅ Automatic team assignment
- ✅ 7-day expiration for invitation tokens
- ✅ Prevent duplicate invitations
- ✅ Track invitation status (pending, accepted, expired)

## Database Schema

### `user_invitations` table
```ruby
- id (bigint, primary key)
- email (string, required, indexed)
- token (string, required, unique, indexed)
- invited_by_id (bigint, required, foreign key to users)
- team_id (bigint, required, foreign key to teams)
- status (enum: 'pending', 'accepted', 'expired')
- expires_at (datetime, required)
- accepted_at (datetime, nullable)
- metadata (jsonb, default: {})
- deleted_at (datetime, nullable - for soft delete)
- timestamps
```

## API Endpoints

### 1. Send Invitations
**POST** `/api/v1/invitations`

Send invitation emails to one or more users.

**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "emails": ["user1@example.com", "user2@example.com"],
  "base_url": "http://localhost:5173"  // Optional, frontend URL
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "successful": [
      {
        "id": 1,
        "email": "user1@example.com",
        "status": "pending",
        "expires_at": "2025-11-21T00:00:00.000Z",
        "days_until_expiration": 7
      }
    ],
    "failed": [],
    "summary": {
      "total": 2,
      "successful_count": 2,
      "failed_count": 0
    }
  },
  "message": "2 convite(s) enviado(s) com sucesso"
}
```

**Response (Partial Failure):**
```json
{
  "success": false,
  "data": {
    "successful": [...],
    "failed": [
      {
        "email": "existing@example.com",
        "errors": ["Email já está cadastrado na plataforma"]
      }
    ],
    "summary": {
      "total": 2,
      "successful_count": 1,
      "failed_count": 1
    }
  }
}
```

**Validation Rules:**
- Maximum 50 emails per request
- Valid email format required
- Email must not be already registered
- Email must not have a pending invitation for the same team

---

### 2. Verify Invitation
**GET** `/api/v1/invitations/:token/verify`

Verify if an invitation token is valid before showing the registration form.

**Authentication:** Not required (public endpoint)

**Response (Valid):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "invitation": {
      "id": 1,
      "email": "newuser@example.com",
      "team_name": "My Law Firm",
      "invited_by": "João Silva",
      "expires_at": "2025-11-21T00:00:00.000Z",
      "days_until_expiration": 5,
      "suggested_role": "lawyer"
    }
  }
}
```

**Response (Invalid/Expired):**
```json
{
  "success": true,
  "data": {
    "valid": false,
    "reason": "Este convite expirou",
    "status": "expired"
  }
}
```

---

### 3. Accept Invitation
**POST** `/api/v1/invitations/:token/accept`

Accept an invitation and create a new user account.

**Authentication:** Not required (public endpoint)

**Request Body:**
```json
{
  "password": "SecurePassword123",
  "password_confirmation": "SecurePassword123",
  "user_profile_attributes": {
    "name": "João",
    "last_name": "Silva",
    "oab": "123456",
    "cpf": "12345678900",
    "gender": "male",
    "birth": "1990-01-01",
    "civil_status": "single",
    "nationality": "brazilian",
    "mother_name": "Maria Silva",
    "rg": "1234567",
    "office_id": 1  // Optional
  }
}
```

**Minimum Required Fields:**
```json
{
  "password": "SecurePassword123",
  "password_confirmation": "SecurePassword123",
  "user_profile_attributes": {
    "name": "João",
    "oab": "123456"  // Required for lawyers
  }
}
```

**Response (Success):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 100,
      "email": "newuser@example.com",
      "team_id": 5,
      "team_name": "My Law Firm",
      "profile": {
        "id": 99,
        "name": "João",
        "last_name": "Silva",
        "full_name": "João Silva",
        "role": "lawyer"
      }
    },
    "invitation": {
      "id": 1,
      "invited_by": {
        "id": 50,
        "name": "Maria Santos"
      },
      "accepted_at": "2025-11-14T12:00:00.000Z"
    },
    "message": "Conta criada com sucesso! Bem-vindo ao Procstudio."
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "errors": ["Este convite expirou"]
}
```

---

### 4. List Team Invitations
**GET** `/api/v1/invitations`

List all invitations sent by users in the current team.

**Authentication:** Required (Bearer token)

**Query Parameters:**
- `status` (optional): Filter by status (`pending`, `accepted`, `expired`)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "email": "newuser@example.com",
      "status": "pending",
      "invited_by": {
        "id": 50,
        "name": "Maria Santos"
      },
      "team_name": "My Law Firm",
      "expires_at": "2025-11-21T00:00:00.000Z",
      "days_until_expiration": 5,
      "accepted_at": null,
      "created_at": "2025-11-14T12:00:00.000Z"
    }
  ]
}
```

---

### 5. Cancel Invitation
**DELETE** `/api/v1/invitations/:id`

Cancel a pending invitation.

**Authentication:** Required (Bearer token)

**Response (Success):**
```json
{
  "success": true,
  "message": "Convite cancelado com sucesso"
}
```

**Response (Error - Not Pending):**
```json
{
  "success": false,
  "errors": ["Apenas convites pendentes podem ser cancelados"]
}
```

---

## Email Configuration

The invitation emails are sent using Mailjet. Emails include:
- Invitation from the inviter's name
- Team name
- Call-to-action button with unique invitation link
- Expiration warning (7 days)
- Plain text version for email clients that don't support HTML

**Email Subject:** `{inviter_name} convidou você para o Procstudio`

---

## Services Architecture

### `Users::Invitations::CreationService`
Handles invitation creation and email sending.

**Usage:**
```ruby
result = Users::Invitations::CreationService.create_invitations(
  emails: ['user1@example.com', 'user2@example.com'],
  current_user: current_user,
  base_url: 'http://localhost:5173'
)

if result.success?
  # Process successful invitations
  result.data[:summary][:successful_count]
else
  # Handle errors
  result.errors
end
```

---

### `Users::Invitations::AcceptanceService`
Handles invitation acceptance and user account creation.

**Usage:**
```ruby
result = Users::Invitations::AcceptanceService.accept_invitation(
  token: invitation_token,
  user_params: {
    password: 'password123',
    password_confirmation: 'password123',
    user_profile_attributes: { name: 'João', oab: '123456' }
  }
)

if result.success?
  user = result.data[:user]
  # User created successfully
else
  # Handle errors
  result.errors
end
```

---

### `Users::Invitations::VerificationService`
Verifies invitation token validity.

**Usage:**
```ruby
result = Users::Invitations::VerificationService.verify_invitation(
  token: invitation_token
)

if result.data[:valid]
  # Show registration form
else
  # Show error message
  result.data[:reason]
end
```

---

### `Users::Mail::InvitationService`
Sends invitation emails via Mailjet.

**Usage:**
```ruby
invitation_url = "http://localhost:5173/accept-invitation/#{invitation.token}"
Users::Mail::InvitationService.new(invitation, invitation_url).call
```

---

## Frontend Integration

### 1. Sending Invitations
```javascript
const response = await fetch('/api/v1/invitations', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    emails: ['user1@example.com', 'user2@example.com'],
    base_url: window.location.origin
  })
});

const data = await response.json();
```

---

### 2. Accepting Invitation Flow

**Step 1:** Verify token when user lands on invitation page
```javascript
const token = params.token;
const response = await fetch(`/api/v1/invitations/${token}/verify`);
const data = await response.json();

if (data.data.valid) {
  // Show registration form with pre-filled email
  showRegistrationForm(data.data.invitation);
} else {
  // Show error message
  showError(data.data.reason);
}
```

**Step 2:** Accept invitation and create account
```javascript
const response = await fetch(`/api/v1/invitations/${token}/accept`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    password: password,
    password_confirmation: passwordConfirmation,
    user_profile_attributes: {
      name: name,
      last_name: lastName,
      oab: oab
    }
  })
});

const data = await response.json();
if (data.success) {
  // Redirect to login or auto-login
  redirectToLogin(data.data.user.email);
}
```

---

## Testing

Run the invitation feature tests:
```bash
# All invitation tests
bundle exec rspec spec/models/user_invitation_spec.rb
bundle exec rspec spec/services/users/invitations/
bundle exec rspec spec/requests/api/v1/invitations_spec.rb

# Specific test file
bundle exec rspec spec/services/users/invitations/creation_service_spec.rb
```

---

## Security Considerations

1. **Token Security**: Tokens are generated using `SecureRandom.urlsafe_base64(32)`
2. **Expiration**: Invitations expire after 7 days
3. **Rate Limiting**: Maximum 50 invitations per request
4. **Validation**: Prevents duplicate invitations and registrations
5. **Authorization**: Only authenticated users can send invitations
6. **Team Isolation**: Users can only invite to their own team

---

## Common Use Cases

### Use Case 1: Law Firm Onboarding
A law firm administrator wants to invite multiple lawyers to join the platform.

```bash
POST /api/v1/invitations
{
  "emails": [
    "lawyer1@lawfirm.com",
    "lawyer2@lawfirm.com",
    "paralegal@lawfirm.com"
  ]
}
```

### Use Case 2: Single Lawyer Invitation
A team member wants to invite one colleague.

```bash
POST /api/v1/invitations
{
  "emails": ["colleague@example.com"]
}
```

### Use Case 3: Checking Invitation Status
View all pending invitations for the team.

```bash
GET /api/v1/invitations?status=pending
```

---

## Troubleshooting

### Problem: Invitation emails not being sent
**Solution:** Check Mailjet configuration in `config/initializers/mailjet.rb` and verify API credentials.

### Problem: "Email já está cadastrado"
**Solution:** The email is already registered. The user should use the login instead.

### Problem: "Este convite expirou"
**Solution:** Request a new invitation. Invitations are valid for 7 days only.

### Problem: "Convite não encontrado"
**Solution:** Verify the token is correct and the invitation hasn't been deleted.

---

## Future Enhancements

Potential improvements for the invitation system:
- [ ] Customizable expiration time
- [ ] Invitation templates with custom messages
- [ ] Resend invitation functionality
- [ ] Bulk invitation via CSV upload
- [ ] Invitation analytics and tracking
- [ ] Role assignment during invitation
- [ ] Multi-language email support

---

## Related Files

**Models:**
- `app/models/user_invitation.rb`
- `app/models/user.rb`
- `app/models/team.rb`

**Controllers:**
- `app/controllers/api/v1/invitations_controller.rb`

**Services:**
- `app/services/users/invitations/creation_service.rb`
- `app/services/users/invitations/acceptance_service.rb`
- `app/services/users/invitations/verification_service.rb`
- `app/services/users/mail/invitation_service.rb`

**Tests:**
- `spec/models/user_invitation_spec.rb`
- `spec/services/users/invitations/creation_service_spec.rb`
- `spec/services/users/invitations/acceptance_service_spec.rb`
- `spec/requests/api/v1/invitations_spec.rb`

**Migrations:**
- `db/migrate/20251114005121_create_user_invitations.rb`
