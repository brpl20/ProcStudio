# UserProfile Model Information

## Attributes

```ruby
UserProfile.new

id, # integer # required*
role, # string
name, # string # required*
last_name, # string
gender, # string
oab, # string # required*
rg, # string
cpf, # string
nationality, # string
civil_status, # string
birth, # date
mother_name, # string
status, # string
user_id, # integer # required*
created_at, # datetime # required*
updated_at, # datetime # required*
office_id, # integer
origin, # string
deleted_at, # datetime
```

## Associations

### Has Many

```ruby
has_many :addresses, as: :addressable, dependent: :destroy, autosave: true
has_many :phones, as: :phoneable, dependent: :destroy, autosave: true
has_many :user_bank_accounts, dependent: :destroy
has_many :bank_accounts, through: :user_bank_accounts, autosave: true
has_many :user_profile_works, dependent: :destroy
has_many :works, through: :user_profile_works
has_many :jobs, dependent: :destroy
```

### Belongs To

```ruby
belongs_to :user, inverse_of: :user_profile, autosave: true
belongs_to :office, optional: true
```

## Validations

```ruby
validates :user, presence: message: :required
validates :name, presence: true
validates :oab, presence: if: :lawyer?
```

## Scopes

```ruby
```

## Callbacks

```ruby
# Callbacks information not available
```

