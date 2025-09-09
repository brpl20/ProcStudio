# Job Model Information

## Related Files

### Model
- `app/models/job.rb`

### Controllers
- `app/controllers/api/v1/jobs_controller.rb`

### Serializers
- `app/serializers/job_serializer.rb`
- `app/serializers/job_serializer.rb`

### Jobs
- `app/jobs/age_transition_checker_job.rb`
- `app/jobs/application_job.rb`
- `app/jobs/draft_cleanup_job.rb`
- `app/jobs/mail_delivery_job.rb`

### Filters
- `app/models/filters/job_filter.rb`


## Attributes

```ruby
Job.new

id, # integer # required*
description, # string
deadline, # date # required*
status, # string
priority, # string
comment, # string
created_at, # datetime # required*
updated_at, # datetime # required*
work_id, # integer
profile_customer_id, # integer
created_by_id, # integer
deleted_at, # datetime
team_id, # integer # required*
```

## Associations

### Has Many

```ruby
has_many :job_user_profiles, dependent: :destroy
has_many :user_profiles, through: :job_user_profiles
has_many :assignees, through: :job_user_profiles, source: :user_profile
has_many :supervisors, through: :job_user_profiles, source: :user_profile
```

### Belongs To

```ruby
belongs_to :team
belongs_to :work, optional: true
belongs_to :profile_customer, optional: true
belongs_to :created_by, class_name: "User"
```

## Validations

```ruby
validates :team, presence: message: :required
validates :created_by, presence: message: :required
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
job = Job.new
# Returns: #<Job ...>
```

### Finder Methods
```ruby
# Find by ID
Job.find(1)
# Returns: #<Job id: 1, ...> or raises ActiveRecord::RecordNotFound

# Find by attributes
Job.find_by(description: 'value')
# Returns: #<Job ...> or nil

# Where clause
Job.where(active: true)
# Returns: ActiveRecord::Relation
```

### Custom Instance Methods
```ruby
job.assign_to_user(...)
# Implement: Check method definition for return value
job.assignees_count(...)
# Implement: Check method definition for return value
job.supervisors_count(...)
# Implement: Check method definition for return value
job.autosave_associated_records_for_team(...)
# Implement: Check method definition for return value
job.autosave_associated_records_for_work(...)
# Implement: Check method definition for return value
```

### Custom Class Methods
```ruby
Job.not_delayed
# Implement: Check method definition for return value
Job.not_finished
# Implement: Check method definition for return value
Job.delayed
# Implement: Check method definition for return value
Job.deleted_inside_time_window
# Implement: Check method definition for return value
Job.deleted_after_time
# Implement: Check method definition for return value
```

## Serializer

### Serializer Class
- **Class**: `JobSerializer`
- **File**: `app/serializers/job_serializer.rb`

### Example Serialized Response
```json
{
  "id": 1,
  "description": "example_description",
  "deadline": "value",
  "status": "example_status",
  "priority": "example_priority",
  "comment": "example_comment",
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z",
  "work_id": 100,
  "profile_customer_id": 100,
  "created_by_id": 100,
  "deleted_at": "2024-01-01T12:00:00Z",
  "team_id": 100,
  "job_user_profiles": [],
  "user_profiles": [],
  "assignees": [],
  "supervisors": [],
  "team": null,
  "work": null,
  "profile_customer": null,
  "created_by": null,
}
```

