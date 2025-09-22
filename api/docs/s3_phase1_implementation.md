# S3 Phase 1 Implementation - Direct Model Attachments

## Overview
Phase 1 implements direct S3 attachments for specific models with simple, predictable file storage patterns.

## Implemented Components

### 1. **S3Service** (`app/services/s3_service.rb`)
Centralized service for all S3 operations:
- `upload(file, s3_key, metadata)` - Upload files to S3
- `delete(s3_key)` - Delete files from S3
- `exists?(s3_key)` - Check if file exists
- `presigned_url(s3_key)` - Generate viewing URLs
- `presigned_download_url(s3_key, filename)` - Generate download URLs
- `copy`, `list_objects`, `get_object_metadata` - Additional utilities

### 2. **S3PathBuilder** (`app/models/concerns/s3_path_builder.rb`)
Concern for generating consistent S3 paths:
- Office logos: `/env/team-{id}/offices/{office-id}/logo/logo-{timestamp}.{ext}`
- Social contracts: `/env/team-{id}/offices/{office-id}/social-contracts/contract-{timestamp}-{hash}.{ext}`
- User avatars: `/env/team-{id}/users/{user-id}/avatar/avatar-{timestamp}.{ext}`

### 3. **S3Attachable** (`app/models/concerns/s3_attachable.rb`)
Concern providing attachment methods for models:

#### Office Methods:
- `upload_logo(file, metadata)` - Upload office logo
- `logo_url(expires_in: 3600)` - Get presigned URL for logo
- `delete_logo!` - Delete logo from S3
- `upload_social_contract(file, metadata)` - Upload social contract
- `social_contracts_with_urls` - Get all contracts with URLs
- `delete_social_contract!(attachment_id)` - Delete specific contract

#### UserProfile Methods:
- `upload_avatar(file, metadata)` - Upload user avatar
- `avatar_url(expires_in: 3600)` - Get presigned URL for avatar
- `delete_avatar!` - Delete avatar from S3

## Database Changes

### Added Columns:
- `user_profiles.avatar_s3_key` - Stores S3 key for user avatars
- `offices.logo_s3_key` - Stores S3 key for office logos (existing)
- `office_attachment_metadata.s3_key` - Stores S3 keys for social contracts (existing)

## Usage Examples

### Upload Office Logo
```ruby
office = Office.find(1)
file = params[:logo]  # From form upload

if office.upload_logo(file, uploaded_by_id: current_user.id)
  # Success - logo uploaded and S3 key saved
  logo_url = office.logo_url  # Get presigned URL
end
```

### Upload User Avatar
```ruby
user_profile = current_user.user_profile
file = params[:avatar]

if user_profile.upload_avatar(file)
  # Success - avatar uploaded
  avatar_url = user_profile.avatar_url
end
```

### Upload Social Contract
```ruby
office = Office.find(1)
file = params[:contract]

if office.upload_social_contract(file, uploaded_by_id: current_user.id)
  # Success - contract uploaded and metadata saved
  contracts = office.social_contracts_with_urls
  # Returns array with URLs for each contract
end
```

### Delete Attachments
```ruby
# Delete logo
office.delete_logo!

# Delete avatar  
user_profile.delete_avatar!

# Delete specific social contract
office.delete_social_contract!(attachment_id)
```

## Configuration

Required environment variables:
```bash
AWS_ACCESS_KEY_ID=your_key_id
AWS_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET=your_bucket_name
AWS_REGION=us-west-2  # Optional, defaults to us-west-2
```

## Testing

Run tests with:
```bash
# Unit tests
rspec spec/services/s3_service_spec.rb
rspec spec/models/concerns/s3_attachable_spec.rb

# Integration test
rails runner rails_runner_tests/test_s3_phase1.rb
```

## Security Features

1. **Team-based isolation**: Files are stored under team-specific paths
2. **Presigned URLs**: All file access uses time-limited presigned URLs
3. **Old file cleanup**: Automatically deletes old files when uploading new ones
4. **Metadata tracking**: Tracks who uploaded files and when

## Next Steps - Phase 2

Phase 2 will implement the shared files pool for multiple model associations:
- `StoredFile` model for deduplication
- `FileReference` for polymorphic associations
- API endpoints for file management
- Advanced features (virus scanning, thumbnails)

## Migration Path

Existing ActiveStorage attachments remain functional. Migration to new system can be done gradually:
1. New uploads use S3Service
2. Existing files continue using ActiveStorage
3. Background job can migrate old files when ready