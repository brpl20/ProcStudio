# User Model Information

## Related Files

### Model
- `app/models/user.rb`

### Controllers
- `/app/controllers/api/v1/users_controller.rb`

### Serializers
- `/app/serializers/user_serializer.rb`
- `/app/serializers/user_serializer.rb`


## Attributes

```ruby
User.new

id, # integer # required*
email, # string # required*
encrypted_password, # string # required*
reset_password_token, # string
reset_password_sent_at, # datetime
remember_created_at, # datetime
created_at, # datetime # required*
updated_at, # datetime # required*
jwt_token, # string
deleted_at, # datetime
status, # string # required*
oab, # string
team_id, # integer # required*
```

## Associations

### Has Many

```ruby
has_many :user_offices, dependent: :destroy
has_many :offices, through: :user_offices
```

### Has One

```ruby
has_one :user_profile, dependent: :destroy, inverse_of: :user, autosave: true
```

### Belongs To

```ruby
belongs_to :team
```

## Validations

```ruby
validates :email, presence: if: :email_required?
validates :email, uniqueness: allow_blank: true, case_sensitive: true, if: :devise_will_save_change_to_email?
validates :email, format: with: /\A[^@\s]+@[^@\s]+\z/, allow_blank: true, if: :devise_will_save_change_to_email?
validates :email, presence: true
validates :password, presence: if: :password_required?
validates :password, confirmation: case_sensitive: true, if: :password_required?
validates :password, length: allow_blank: true, minimum: 6, maximum: 128
validates :team, presence: message: :required
```

## Scopes

```ruby
```

## Callbacks

```ruby
# Callbacks information not available
```

## Key Methods & Usage Examples

### Instance Creation
```ruby
user = User.new
# Returns: #<User ...>
```

### Finder Methods
```ruby
# Find by ID
User.find(1)
# Returns: #<User id: 1, ...> or raises ActiveRecord::RecordNotFound

# Find by attributes
User.find_by(email: 'user@example.com')
# Returns: #<User ...> or nil

# Where clause
User.where(active: true)
# Returns: ActiveRecord::Relation
```

### Custom Instance Methods
```ruby
user.validate_associated_records_for_offices(...)
# Implement: Check method definition for return value
user.autosave_associated_records_for_team(...)
# Implement: Check method definition for return value
user.paranoid_configuration
# Implement: Check method definition for return value
user.user_profile_id
# Implement: Check method definition for return value
user.autosave_associated_records_for_user_profile(...)
# Implement: Check method definition for return value
```

### Custom Class Methods
```ruby
User.not_inactive
# Implement: Check method definition for return value
User.deleted_inside_time_window
# Implement: Check method definition for return value
User.deleted_after_time
# Implement: Check method definition for return value
User.deleted_before_time
# Implement: Check method definition for return value
User.devise_modules
# Implement: Check method definition for return value
```

## Serializer

### Serializer Class
- **Class**: `UserSerializer`
- **File**: `app/serializers/user_serializer.rb`

### Example Serialized Response
```json
{
  "id": 1,
  "email": "example_email",
  "encrypted_password": "example_encrypted_password",
  "reset_password_token": "example_reset_password_token",
  "reset_password_sent_at": "2024-01-01T12:00:00Z",
  "remember_created_at": "2024-01-01T12:00:00Z",
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z",
  "jwt_token": "example_jwt_token",
  "deleted_at": "2024-01-01T12:00:00Z",
  "status": "example_status",
  "oab": "example_oab",
  "team_id": 100,
  "user_offices": [],
  "offices": [],
  "user_profile": null,
  "team": null,
}
```

