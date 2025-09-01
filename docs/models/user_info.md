# User Model Information

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

