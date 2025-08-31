# Enum Methods Automáticos
```
profile.able?
profile.relatively?
profile.unable?
```

## Prefix
Cuidar com uso dos `prefix` se eles constarem nos enums seria `profile.capacity.able?`

# Model Helpers
- `UserProfile.reflect_on_all_associations.map(&:plural_name)`
- `Work.columns_hash.map { |name, col| [name, col.type] }.to_h`
- `Model.column_names`
- `Model.columns`
- `Model.columns_hash`

# Model.new Helpers
```ruby
m = Model.new
m.valid?                  # Check if model is valid
m.errors.full_messages    # See validation error messages
Model.validators          # List all validators
```
# Routes e Info
Rails.application.routes.routes    # Inspect all routes
Rails.application.config           # View application config
Rails.env                          # Current environment

# Jobs
job.assignees           # Todos os responsáveis principais
job.supervisors         # Todos os supervisores
job.primary_assignee    # Primeiro responsável
job.all_members         # Todos os envolvidos
job.add_assignee(user_profile, role: 'assignee')
job.remove_assignee(user_profile)
