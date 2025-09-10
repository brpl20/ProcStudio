# Work Model Information

## Attributes

```ruby
Work.new

id, # integer
number, # integer
rate_parceled_exfield, # string
folder, # string
note, # string
extra_pending_document, # string
created_at, # datetime
updated_at, # datetime
other_description, # text
compensations_five_years, # boolean
compensations_service, # boolean
lawsuit, # boolean
gain_projection, # string
physical_lawyer, # integer
responsible_lawyer, # integer
partner_lawyer, # integer
intern, # integer
bachelor, # integer
initial_atendee, # integer
created_by_id, # integer
deleted_at, # datetime
team_id, # integer
law_area_id, # integer
work_status, # string
```

## Associations

### Has Many

```ruby
has_many :customer_works, dependent: :destroy, autosave: true
has_many :profile_customers, through: :customer_works
has_many :user_profile_works, dependent: :destroy, autosave: true
has_many :user_profiles, through: :user_profile_works
has_many :power_works, dependent: :destroy
has_many :powers, through: :power_works
has_many :documents, dependent: :destroy, autosave: true
has_many :pending_documents, dependent: :destroy, autosave: true
has_many :office_works, dependent: :destroy
has_many :offices, through: :office_works
has_many :recommendations, dependent: :destroy, autosave: true
has_many :work_events, dependent: :destroy
has_many :jobs
has_many :procedures, dependent: :destroy, autosave: true
has_many :root_procedures, class_name: "Procedure"
has_many :honoraries, dependent: :destroy, autosave: true
```

### Has One

```ruby
has_one :global_honorary, class_name: "Honorary"
has_one :draft_work, class_name: "Draft::Work", dependent: :destroy
```

### Belongs To

```ruby
belongs_to :team
belongs_to :law_area, optional: true
```

## Validations

```ruby
validates :team, presence: message: :required
validates :law_area, presence: true
validates_with WorkAddressesValidator
```

## Scopes

```ruby
```

## Callbacks

```ruby
# Callbacks information not available
```

