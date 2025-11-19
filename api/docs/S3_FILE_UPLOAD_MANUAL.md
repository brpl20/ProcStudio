# S3 File Upload Manual - ProcStudio API

## Overview
We've completely replaced ActiveStorage with a custom S3 file management system. This provides better control, performance, and organization of files in S3.

## Key Changes

### 1. Database Structure
- **New table**: `file_metadata` - Universal file tracking with polymorphic associations
- **Removed**: All ActiveStorage tables (active_storage_blobs, active_storage_attachments, etc.)
- **Added**: `logo_s3_key` and `avatar_s3_key` columns to offices and user_profiles tables

### 2. Core Components

#### FileMetadata Model
```ruby
# Universal file tracking model
FileMetadata
  - attachable (polymorphic)   # Can be Office, UserProfile, Job, Work, etc.
  - s3_key                      # S3 path
  - filename                    # Original filename
  - content_type                # MIME type
  - byte_size                   # File size in bytes
  - checksum                    # SHA256 for deduplication
  - created_by_system           # Boolean - true for system-generated files
  - uploaded_by                 # UserProfile who uploaded
  - file_category               # Type: logo, avatar, social_contract, etc.
  - metadata                    # JSON hash with custom data
  - uploaded_at                 # Timestamp of upload
  - expires_at                  # Optional expiry date
```

#### S3Manager Service
Singleton service for all S3 operations:

**Basic Methods:**
- `upload(file, model: nil, path: nil, system_generated: false, user_profile: nil, metadata: {})`
- `download(file_metadata)`
- `delete(file_metadata)`
- `move(file_metadata, to_model, options = {})`
- `copy(file_metadata, to_model, options = {})`
- `list(scope, filters = {})`
- `url(file_metadata, type: :view, expires_in: 3600)`
- `stream(file_metadata, &block)`

**System-Generated Files - Social Contract Example:**
```ruby
# In OfficesController#process_social_contract_generation
File.open(file_path, 'rb') do |file|
  # Create a wrapper for the generated DOCX file
  uploaded_file = ContractFileWrapper.new(file, file_path)

  # Upload with system_generated flag
  file_metadata = office.upload_social_contract(
    uploaded_file,
    user_profile: current_user.user_profile,
    system_generated: true,  # Mark as system-generated
    document_date: Date.current,
    description: "Contrato Social gerado automaticamente para #{office.name}"
  )
end
```

**User-Uploaded Files Example:**
```ruby
# Regular file upload
file_metadata = office.upload_social_contract(
  params[:contract],
  user_profile: current_user.user_profile,
  system_generated: false,  # User-uploaded file
  document_date: params[:document_date],
  description: params[:description]
)
```

#### PathGenerator Module
Generates consistent S3 paths with automatic extension detection:

**Path Structure:**
```
{environment}/team-{team_id}/{model_type}/{model_id}/{file_type}/{filename-timestamp-hash}.{ext}
```

**Features:**
- Automatically extracts file extension from original filename
- Uses correct extension for each file type (e.g., `.docx` for Word documents, `.pdf` for PDFs)
- Falls back to sensible defaults if no extension provided

**Examples:**
```
# Logo with PNG extension
development/team-31/offices/37/logo/logo-20251117195134.png

# System-generated social contract (DOCX)
development/team-31/offices/37/social-contracts/contract-20251118234648-abc123.docx

# User-uploaded social contract (PDF)
development/team-31/offices/37/social-contracts/contract-20251118234649-def456.pdf
```

## API Endpoints

### Endpoint Pattern Summary
The API provides two patterns for file uploads:

1. **Specific endpoints** for predefined file types:
   - Office Logo: `POST /api/v1/offices/:id/upload_logo`
   - Office Social Contracts: `POST /api/v1/offices/:id/upload_contracts`
   - UserProfile Avatar: `POST /api/v1/user_profiles/:id/upload_avatar`

2. **Generic endpoints** for polymorphic attachments:
   - Job Attachments: `POST /api/v1/jobs/:id/upload_attachment`
   - Work Documents: `POST /api/v1/works/:id/upload_document`
   - These endpoints work with the polymorphic FileMetadata model

### Office Logo Upload
```http
POST /api/v1/offices/:id/upload_logo
Content-Type: multipart/form-data

Parameters:
- logo: File (JPEG, PNG, GIF, WEBP)

Response:
{
  "success": true,
  "message": "Logo enviado com sucesso",
  "data": {
    "logo_url": "https://s3-presigned-url...",
    "file_metadata_id": 123
  }
}
```

### UserProfile Avatar Upload
```http
POST /api/v1/user_profiles/:id/upload_avatar
Content-Type: multipart/form-data

Parameters:
- avatar: File (JPEG, PNG, GIF, WEBP)

Response:
{
  "success": true,
  "message": "Avatar enviado com sucesso",
  "data": {
    "id": 61,
    "avatar_url": "https://s3-presigned-url...",
    "file_metadata_id": 456
  }
}
```

### Office Social Contracts Upload
```http
POST /api/v1/offices/:id/upload_contracts
Content-Type: multipart/form-data

Parameters:
- contracts[]: Files (PDF, DOCX) - supports multiple
- document_date: Date (optional)
- description: String (optional, e.g., "1a Alteração")

Response:
{
  "success": true,
  "message": "3 contrato(s) adicionado(s) com sucesso",
  "uploaded_count": 3
}
```

### Job Attachment Upload (Generic Polymorphic)
```http
POST /api/v1/jobs/:id/upload_attachment
Content-Type: multipart/form-data

Parameters:
- attachment: File (any format)
- description: String (optional)
- document_date: Date (optional)

Response:
{
  "success": true,
  "message": "Anexo enviado com sucesso",
  "data": {
    "id": 1,
    "file_metadata_id": 789,
    "filename": "report.pdf",
    "url": "https://s3-presigned-url...",
    "byte_size": 1024000,
    "content_type": "application/pdf"
  }
}
```

### Job Attachment Removal
```http
DELETE /api/v1/jobs/:id/attachments/:attachment_id

Response:
{
  "success": true,
  "message": "Anexo removido com sucesso",
  "data": { "id": 1, "attachment_id": "789" }
}
```

### Work Document Upload (Typed Documents)
```http
POST /api/v1/works/:id/upload_document
Content-Type: multipart/form-data

Parameters:
- document: File (PDF, DOCX)
- document_type: String (required - procuration, waiver, deficiency_statement, honorary)
- description: String (optional)
- document_date: Date (optional)

Response:
{
  "success": true,
  "message": "Documento enviado com sucesso",
  "data": {
    "id": 1,
    "file_metadata_id": 890,
    "filename": "procuration.pdf",
    "document_type": "procuration",
    "url": "https://s3-presigned-url...",
    "byte_size": 512000,
    "content_type": "application/pdf"
  }
}
```

### Work Document Removal
```http
DELETE /api/v1/works/:id/documents/:document_id

Response:
{
  "success": true,
  "message": "Documento removido com sucesso",
  "data": { "id": 1, "document_id": "890" }
}
```

## Model Methods

### Office Model
```ruby
office = Office.find(id)

# Logo management
office.upload_logo(file, user_profile: current_user.user_profile, **options)
office.logo                # Returns FileMetadata object
office.logo_url(expires_in: 3600)  # Returns presigned S3 URL
office.logo&.destroy       # Deletes logo

# Social contracts
office.upload_social_contract(
  file,
  user_profile: current_user.user_profile,
  system_generated: false,  # Set to true for auto-generated contracts
  **options
)
office.social_contracts    # Returns FileMetadata collection
office.social_contract_urls(expires_in: 3600) # Returns array of presigned URLs
office.delete_social_contract(file_metadata_id)

# Identifying system-generated contracts
office.social_contracts.where(created_by_system: true)  # System-generated
office.social_contracts.where(created_by_system: false) # User-uploaded
```

### UserProfile Model
```ruby
profile = UserProfile.find(id)

# Avatar management
profile.upload_avatar(file, user_profile: current_user.user_profile)
profile.avatar_url(only_path: nil)  # only_path parameter ignored (always returns full URL)
profile.avatar              # Returns FileMetadata object
profile.delete_avatar       # Deletes avatar
```

### Job Model
```ruby
job = Job.find(id)

# Attachments
job.upload_attachment(file, user_profile: current_user.user_profile)
job.attachments           # Returns FileMetadata collection
job.attachment_urls       # Returns array of presigned URLs
job.delete_attachment(file_metadata_id)
```

### Work Model
```ruby
work = Work.find(id)

# Document types: procuration, waiver, deficiency_statement, honorary
work.upload_document(file, document_type: 'procuration', user_profile: profile)
work.work_documents       # Returns all documents
work.documents_by_type('procuration')  # Filter by type
work.document_urls        # Returns array of presigned URLs
work.delete_document(file_metadata_id)
```

## File Validations

### Image Files (Logo/Avatar)
- Accepted formats: JPEG, PNG, GIF, WEBP
- Auto-replacement: Uploading a new logo/avatar deletes the old one

### Document Files (Contracts/Attachments)
- Accepted formats: PDF, DOCX
- Multiple files: Social contracts support multiple files per office

## S3 Organization

```
bucket/
├── development/
│   └── team-31/
│       ├── offices/
│       │   └── 37/
│       │       ├── logo/
│       │       │   └── logo-20251117195134.png
│       │       └── social-contracts/
│       │           ├── contract-20251117194851-5b0ae3.pdf        # User-uploaded
│       │           ├── contract-20251117195104-4d85f5.docx      # System-generated
│       │           └── contract-20251118234648-abc123.docx      # System-generated
│       ├── user-profiles/
│       │   └── 61/
│       │       └── avatar/
│       │           └── avatar-20251117195136.jpg
│       ├── jobs/
│       │   └── 1/
│       │       └── attachment/
│       │           └── attachment-20251118-abc123.pdf
│       └── works/
│           └── 1/
│               └── procuration/
│                   └── procuration-20251118-def456.pdf
└── production/
    └── team-1/
        └── ...
```

## Migration from ActiveStorage

### What Changed
1. **No more ActiveStorage** - All `has_one_attached` and `has_many_attached` removed
2. **Direct S3 URLs** - Presigned URLs generated directly from S3
3. **UserProfile-centric** - All uploads tracked by UserProfile, not User
4. **Polymorphic associations** - Single FileMetadata model for all file types
5. **Smart deduplication** - Files with same checksum not re-uploaded

### Breaking Changes
- `avatar.attached?` → `avatar.present?`
- `rails_blob_url(avatar)` → `avatar_url`
- ActiveStorage migrations removed
- All existing file references need updating

## Background Jobs

### S3CleanupJob
- Runs daily at 2 AM
- Removes orphaned files from S3
- Cleans expired temporary uploads

### S3ChecksumJob
- Verifies file integrity
- Updates missing checksums
- Reports corrupted files

### S3MetricsJob
- Collects storage usage per team
- Tracks file types and sizes
- Generates usage reports

## Accessing File Metadata

### Through Model Associations
```ruby
# Get metadata for a file
office = Office.find(id)
metadata = office.logo

# Access metadata fields
metadata.id
metadata.s3_key
metadata.filename
metadata.content_type
metadata.byte_size
metadata.checksum
metadata.created_by_system    # true for system-generated
metadata.uploaded_by          # UserProfile who uploaded
metadata.metadata             # Custom metadata hash
metadata.metadata['description']
metadata.metadata['document_date']
metadata.url                  # Presigned S3 URL
```

### Querying FileMetadata
```ruby
# Find system-generated files
FileMetadata.system_generated

# Find user-uploaded files
FileMetadata.user_uploaded

# Find by category
FileMetadata.by_category('social_contract')

# Find by uploader
FileMetadata.where(uploaded_by: user_profile)

# Find files for a specific model
FileMetadata.where(attachable: office)
```

## Testing

### Test file upload in console
```ruby
# Create test file
file = File.open('test.jpg', 'rb')

# Upload logo
office = Office.first
metadata = office.upload_logo(
  file,
  user_profile: UserProfile.first,
  description: "Company logo"
)
puts office.logo_url

# Upload avatar
profile = UserProfile.first
metadata = profile.upload_avatar(file, user_profile: profile)
puts profile.avatar_url

# Upload social contract (user-uploaded)
pdf = File.open('contract.pdf', 'rb')
metadata = office.upload_social_contract(
  pdf,
  user_profile: profile,
  system_generated: false,
  description: "1a Alteração"
)
puts office.social_contract_urls

# Check if contract is system-generated
office.social_contracts.each do |contract|
  puts "#{contract.filename}: System-generated? #{contract.created_by_system}"
end
```

## Troubleshooting

### Common Issues

1. **"FileMetadatum" error**: The model uses irregular pluralization
   - Solution: Use `class_name: 'FileMetadata'` in associations

2. **Missing avatar_url parameter**: Legacy code expects `only_path`
   - Solution: Method accepts but ignores the parameter

3. **Upload fails silently**: Check Rails logs for S3 errors
   - Solution: Ensure AWS credentials and bucket permissions are correct

4. **Files not accessible**: Presigned URLs expired
   - Solution: Default expiry is 1 hour, increase with `expires_in` parameter

5. **Wrong file extension in S3**: Files saved with incorrect extension
   - Solution: PathGenerator now extracts extension from filename automatically
   - System-generated DOCX files will use `.docx`, PDFs will use `.pdf`

6. **"wrong number of arguments" error**: Method signatures changed
   - Solution: Use keyword arguments for upload methods (see examples above)

## Security Notes

- All S3 URLs are presigned with 1-hour expiry by default
- Files are private by default in S3
- Upload permissions checked via Pundit policies
- File checksums prevent duplicate uploads
- UserProfile tracking ensures accountability

## Frontend Integration

For form implementation in React/Svelte:

```javascript
// Logo upload
const formData = new FormData();
formData.append('logo', fileInput.files[0]);

fetch(`/api/v1/offices/${officeId}/upload_logo`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

// Multiple social contracts
const formData = new FormData();
formData.append('contracts[]', file1);
formData.append('contracts[]', file2);
formData.append('description', '1a Alteração');

fetch(`/api/v1/offices/${officeId}/upload_contracts`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

## Environment Variables

Required in `.env`:
```bash
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-west-2
S3_BUCKET=prcstudio3herokubucket
```

## Support

For issues or questions about the new S3 system:
1. Check Rails logs for detailed error messages
2. Verify S3 bucket permissions in AWS Console
3. Ensure FileMetadata records exist in database
4. Test with the provided console commands

Last Updated: November 19, 2024