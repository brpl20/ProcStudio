# Office Model Information

## Attributes

```ruby
Office.new

id, # integer # required*
name, # string # required*
cnpj, # string # required*
oab_id, # string
society, # string
foundation, # date
site, # string
created_at, # datetime # required*
updated_at, # datetime # required*
accounting_type, # string
deleted_at, # datetime
team_id, # integer # required*
oab_status, # string
oab_inscricao, # string
oab_link, # string
created_by_id, # integer
deleted_by_id, # integer
quote_value, # decimal
number_of_quotes, # integer
```

## Associations

### Has Many

```ruby
has_many :user_offices, dependent: :destroy, autosave: true
has_many :users, through: :user_offices
has_many :compensations, through: :user_offices, class_name: "UserSocietyCompensation"
has_many :user_profiles, dependent: :nullify
has_many :social_contracts_attachments, as: :record, class_name: "ActiveStorage::Attachment", inverse_of: :record, dependent: :destroy, strict_loading: false
has_many :social_contracts_blobs, through: :social_contracts_attachments, class_name: "ActiveStorage::Blob", source: :blob, strict_loading: false
has_many :attachment_metadata, class_name: "OfficeAttachmentMetadata", dependent: :destroy
has_many :phones, as: :phoneable, dependent: :destroy, autosave: true
has_many :addresses, as: :addressable, dependent: :destroy, autosave: true
has_many :office_emails, dependent: :destroy
has_many :emails, through: :office_emails, autosave: true
has_many :office_bank_accounts, dependent: :destroy
has_many :bank_accounts, through: :office_bank_accounts, autosave: true
has_many :office_works, dependent: :destroy
has_many :works, through: :office_works
```

### Has One

```ruby
has_one :logo_attachment, class_name: "ActiveStorage::Attachment", as: :record, inverse_of: :record, dependent: :destroy, strict_loading: false
has_one :logo_blob, through: :logo_attachment, class_name: "ActiveStorage::Blob", source: :blob, strict_loading: false
```

### Belongs To

```ruby
belongs_to :team
belongs_to :created_by, class_name: "User", optional: true
belongs_to :deleted_by, class_name: "User", optional: true
```

## Validations

```ruby
validates :cnpj, presence: true
validates :cnpj, uniqueness: true
validates :team, presence: message: :required
validates :name, presence: true
```

## Scopes

```ruby
```

## Callbacks

```ruby
# Callbacks information not available
```

