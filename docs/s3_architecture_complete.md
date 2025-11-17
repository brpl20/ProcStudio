# S3 Architecture - Complete Documentation

**Generated:** 2024-11-16
**Author:** Claude Code Analysis
**Status:** Comprehensive Deep-Dive

---

## Table of Contents

1. [Overall S3 Architecture](#1-overall-s3-architecture)
2. [Core Components Architecture](#2-core-components-architecture)
3. [File Upload Flow (Detailed)](#3-file-upload-flow-detailed)
4. [Social Contract Upload Flow (Multi-file)](#4-social-contract-upload-flow-multi-file)
5. [Auto-Generated Social Contract Flow](#5-auto-generated-social-contract-flow)
6. [URL Generation & Access Flow](#6-url-generation--access-flow)
7. [Class Relationships Diagram](#7-class-relationships-diagram)
8. [Configuration & Initialization](#8-configuration--initialization)
9. [Security & Multi-Tenancy](#9-security--multi-tenancy)
10. [Key Observations & Recommendations](#10-key-observations--recommendations)
11. [Testing Utilities](#11-testing-utilities)
12. [Component Reference](#12-component-reference)

---

## 1. OVERALL S3 ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AWS S3 BUCKET STRUCTURE                         │
│                    (procstudio-bucket or AWS_BUCKET_MAIN)               │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
   ┌────▼─────┐              ┌──────▼──────┐           ┌───────▼────────┐
   │development│              │   staging   │           │  production    │
   └────┬─────┘              └──────┬──────┘           └───────┬────────┘
        │                           │                           │
        │                    (same structure)            (same structure)
        │
   ┌────▼─────────────────────────────────────────────┐
   │         team-{team_id}/  (Multi-tenancy)         │
   └────┬─────────────────────────────────────────────┘
        │
        ├─── offices/
        │     └── {office_id}/
        │          ├── logo/
        │          │    └── logo-20240115143022.png
        │          └── social-contracts/
        │               └── contract-20240115143022-a3f2d1.pdf
        │
        ├─── users/
        │     └── {user_id}/
        │          └── avatar/
        │               └── avatar-20240115143022.jpg
        │
        ├─── works/
        │     └── {work_id}/
        │          └── documents/
        │               ├── procuration/
        │               ├── waiver/
        │               ├── deficiency_statement/
        │               └── honorary/
        │
        └─── profile-customers/
              └── {customer_id}/
                   └── documents/
                        └── {filename}-{timestamp}.ext
```

### Path Examples

| Entity | Example Path |
|--------|-------------|
| Office Logo | `development/team-31/offices/123/logo/logo-20240115143022.png` |
| Social Contract | `development/team-31/offices/123/social-contracts/contract-20240115143022-a3f2d1.pdf` |
| User Avatar | `development/team-31/users/456/avatar/avatar-20240115143022.jpg` |
| Work Document | `development/team-31/works/789/documents/procuration/doc-20240115143022.docx` |
| Customer File | `development/team-31/profile-customers/101/documents/rg-20240115143022.pdf` |

---

## 2. CORE COMPONENTS ARCHITECTURE

```
┌──────────────────────────────────────────────────────────────────┐
│                    RAILS APPLICATION                              │
└──────────────────────────────────────────────────────────────────┘
                              │
     ┌────────────────────────┼────────────────────────┐
     │                        │                        │
┌────▼─────┐          ┌──────▼──────┐         ┌───────▼────────┐
│ Models   │          │ Controllers │         │  Serializers   │
│          │          │             │         │                │
│ Office   │◄─────────┤ Offices     │────────►│ Office         │
│ User     │          │ UserProfiles│         │ UserProfile    │
│ Profile  │          │             │         │                │
└────┬─────┘          └──────┬──────┘         └────────────────┘
     │                       │
     │ includes              │ uses
     │                       │
     ├─── S3Attachable ◄─────┤
     │    └── upload_logo()
     │    └── upload_avatar()
     │    └── logo_url()
     │    └── delete_logo!()
     │
     └─── S3PathBuilder ◄────┤
          └── build_logo_s3_key()
          └── build_avatar_s3_key()
          └── generate_presigned_url()
                              │
                              │ calls
                              ▼
                    ┌──────────────────┐
                    │   S3Service      │◄──── Singleton
                    │  (Centralized)   │
                    └────────┬─────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
      ┌─────▼─────┐    ┌────▼────┐    ┌──────▼──────┐
      │  upload   │    │ delete  │    │presigned_url│
      └───────────┘    └─────────┘    └─────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   AWS S3 SDK    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  AWS S3 Bucket  │
                    └─────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Location |
|-----------|---------------|----------|
| **S3Service** | Low-level S3 operations, AWS SDK wrapper | `app/services/s3_service.rb` |
| **S3PathBuilder** | Generate consistent S3 paths | `app/models/concerns/s3_path_builder.rb` |
| **S3Attachable** | High-level upload/download/delete methods | `app/models/concerns/s3_attachable.rb` |
| **Models** | Business logic, data validation | `app/models/` |
| **Controllers** | HTTP request handling | `app/controllers/api/v1/` |
| **Serializers** | JSON response formatting | `app/serializers/` |

---

## 3. FILE UPLOAD FLOW (Detailed)

### Office Logo Upload Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OFFICE LOGO UPLOAD EXAMPLE                        │
└─────────────────────────────────────────────────────────────────────┘

1. CLIENT REQUEST
   POST /api/v1/offices/123/upload_logo
   Content-Type: multipart/form-data
   Body: { logo: File, description: "Company Logo" }
            │
            ▼
2. CONTROLLER (OfficesController#upload_logo)
   ┌─────────────────────────────────────────┐
   │ - Validate authorization                │
   │ - Extract parameters                    │
   │ - Call LogoUploadService                │
   └───────────────┬─────────────────────────┘
                   ▼
3. SERVICE LAYER (Offices::LogoUploadService)
   ┌─────────────────────────────────────────┐
   │ - Validate content type (image/*)       │
   │ - Validate file presence                │
   │ - Build metadata                        │
   │ - Call office.upload_logo()             │
   └───────────────┬─────────────────────────┘
                   ▼
4. MODEL CONCERN (S3Attachable#upload_logo)
   ┌─────────────────────────────────────────┐
   │ - Initialize LogoUploader               │
   │ - Call uploader.upload()                │
   └───────────────┬─────────────────────────┘
                   ▼
5. UPLOADER CLASS (LogoUploader#upload)
   ┌─────────────────────────────────────────┐
   │ - Extract file extension                │
   │ - Build S3 key via S3PathBuilder        │
   │   → "dev/team-31/offices/123/logo/      │
   │      logo-20240115143022.png"           │
   │ - Delete old logo if exists             │
   │ - Prepare metadata                      │
   │ - Call S3Service.upload()               │
   └───────────────┬─────────────────────────┘
                   ▼
6. S3 SERVICE (S3Service.upload)
   ┌─────────────────────────────────────────┐
   │ - Normalize file input (handle various  │
   │   file types: UploadedFile, Tempfile)   │
   │ - Detect content type                   │
   │ - Build S3 metadata hash                │
   │ - Call AWS SDK put_object()             │
   └───────────────┬─────────────────────────┘
                   ▼
7. AWS S3
   ┌─────────────────────────────────────────┐
   │ File stored at:                         │
   │ s3://procstudio-bucket/development/     │
   │ team-31/offices/123/logo/               │
   │ logo-20240115143022.png                 │
   └───────────────┬─────────────────────────┘
                   ▼
8. DATABASE UPDATE (LogoUploader#handle_successful_upload)
   ┌─────────────────────────────────────────┐
   │ office.update!(                         │
   │   logo_s3_key: "development/team-31/    │
   │     offices/123/logo/                   │
   │     logo-20240115143022.png"            │
   │ )                                       │
   └───────────────┬─────────────────────────┘
                   ▼
9. RESPONSE
   {
     "success": true,
     "message": "Logo atualizado com sucesso",
     "data": {
       "id": 123,
       "logo_url": "https://s3.amazonaws.com/..."
     }
   }
```

### Key Steps Explained

1. **Client Request**: Multipart form data with file
2. **Controller**: Authorization and parameter extraction
3. **Service Layer**: Business logic validation
4. **Model Concern**: Delegation to uploader
5. **Uploader**: Path generation and old file cleanup
6. **S3 Service**: AWS SDK interaction
7. **AWS S3**: Physical storage
8. **Database**: Reference storage (S3 key)
9. **Response**: Success confirmation with URL

---

## 4. SOCIAL CONTRACT UPLOAD FLOW (Multi-file)

```
┌──────────────────────────────────────────────────────────────┐
│          SOCIAL CONTRACT UPLOAD (Multiple Files)             │
└──────────────────────────────────────────────────────────────┘

CLIENT REQUEST
POST /api/v1/offices/123/upload_contracts
Body: {
  contracts: [file1.pdf, file2.docx],
  document_date: "2024-01-15",
  description: "Updated contracts"
}
        │
        ▼
CONTROLLER (OfficesController#upload_contracts)
        │
        ▼
SERVICE (Offices::ContractsUploadService)
┌───────────────────────────────────────────────────┐
│ for each contract in contracts:                   │
│   1. Validate content type (pdf/docx)             │
│   2. Build metadata for this file                 │
│   3. Call office.upload_social_contract(file)     │
│   4. Collect success/error results                │
│                                                    │
│ Return: {                                         │
│   success: true/false,                            │
│   uploaded_count: 2,                              │
│   message: "2 contracts uploaded",                │
│   errors: []                                      │
│ }                                                 │
└───────────────────────────────────────────────────┘
        │
        ▼
MODEL (S3Attachable#upload_social_contract)
        │
        ▼
UPLOADER (SocialContractUploader)
┌───────────────────────────────────────────────────┐
│ 1. Build S3 key with hash:                        │
│    "dev/team-31/offices/123/social-contracts/     │
│     contract-20240115143022-a3f2d1.pdf"           │
│                                                    │
│ 2. Upload to S3                                   │
│                                                    │
│ 3. Create OfficeAttachmentMetadata:               │
│    - document_type: 'social_contract'             │
│    - s3_key: "dev/team-31/..."                    │
│    - filename: "file1.pdf"                        │
│    - content_type: "application/pdf"              │
│    - byte_size: 524288                            │
│    - uploaded_by_id: 76                           │
│                                                    │
│ Note: No update to office.logo_s3_key             │
│       Uses separate metadata table instead        │
└───────────────────────────────────────────────────┘
```

### Metadata Table vs Direct Column

| Approach | Use Case | Example |
|----------|----------|---------|
| **Direct Column** (`logo_s3_key`) | Single file per model | Office logo, User avatar |
| **Metadata Table** (`OfficeAttachmentMetadata`) | Multiple files per model | Social contracts |

---

## 5. AUTO-GENERATED SOCIAL CONTRACT FLOW

```
┌──────────────────────────────────────────────────────────────┐
│     AUTO-GENERATE SOCIAL CONTRACT ON OFFICE CREATION         │
└──────────────────────────────────────────────────────────────┘

CLIENT REQUEST
POST /api/v1/offices
Body: {
  office: {
    name: "Example Law Firm",
    create_social_contract: true,  ← Trigger flag
    user_offices_attributes: [...]
  }
}
        │
        ▼
CONTROLLER (OfficesController#create)
┌─────────────────────────────────────────────────┐
│ 1. @office = build_office                       │
│ 2. @office.save ✓                               │
│ 3. process_file_uploads()                       │
│     │                                            │
│     └─► if should_generate_social_contract?     │
│           process_social_contract_generation()  │
└───────────────────┬─────────────────────────────┘
                    ▼
DOCX GENERATION (DocxServices)
┌─────────────────────────────────────────────────┐
│ 1. SocialContractServiceFacade.new(office_id)   │
│    ├── Check lawyers count                      │
│    ├── If 1 lawyer → Unipessoal service         │
│    └── If 2+ lawyers → Society service          │
│                                                  │
│ 2. service.call()                                │
│    ├── Load template (CS-TEMPLATE.docx)         │
│    ├── Substitute placeholders                  │
│    ├── Insert partner tables                    │
│    └── Save to output/cs-{office-name}.docx     │
│                                                  │
│ 3. Returns: file_path                           │
└───────────────────┬─────────────────────────────┘
                    ▼
FILE UPLOAD (process_social_contract_generation)
┌─────────────────────────────────────────────────┐
│ 1. Open generated file                          │
│ 2. Wrap in ContractFileWrapper                  │
│    (mimics UploadedFile interface)              │
│ 3. office.upload_social_contract(wrapper)       │
│    → Uploads to S3                              │
│    → Creates OfficeAttachmentMetadata           │
│ 4. Delete temp file (production only)           │
└─────────────────────────────────────────────────┘
        │
        ▼
RESULT
Office created with auto-generated contract in S3
s3://bucket/dev/team-31/offices/60/social-contracts/
  contract-20241115183043-xyz123.docx
```

### ContractFileWrapper

A utility class that makes generated files compatible with the S3 upload interface:

```ruby
class ContractFileWrapper
  attr_reader :original_filename, :content_type

  def initialize(file, file_path)
    @file = file
    @original_filename = File.basename(file_path)
    @content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  end

  def read(*args)
    @file.read(*args)
  end

  def size
    @file.size
  end

  def rewind
    @file.rewind
  end
end
```

---

## 6. URL GENERATION & ACCESS FLOW

```
┌──────────────────────────────────────────────────────────────┐
│              PRESIGNED URL GENERATION FLOW                    │
└──────────────────────────────────────────────────────────────┘

CLIENT REQUEST
GET /api/v1/offices/123
        │
        ▼
CONTROLLER (OfficesController#show)
        │
        ▼
SERIALIZER (OfficeSerializer)
┌─────────────────────────────────────────────────┐
│ attributes :logo_url, :social_contracts         │
│                                                  │
│ def logo_url                                    │
│   object.logo_url(expires_in: 3600)             │
│ end                                             │
└───────────────────┬─────────────────────────────┘
                    ▼
MODEL (Office#logo_url)
┌─────────────────────────────────────────────────┐
│ 1. Check if logo_s3_key exists                  │
│ 2. Call generate_presigned_url(logo_s3_key)     │
└───────────────────┬─────────────────────────────┘
                    ▼
S3PathBuilder (generate_presigned_url)
        │
        ▼
S3Service.presigned_url(s3_key, expires_in: 3600)
┌─────────────────────────────────────────────────┐
│ Uses AWS SDK Presigner:                         │
│   - Creates time-limited URL                    │
│   - Expires in 3600 seconds (1 hour)            │
│   - Signed with AWS credentials                 │
│   - No public bucket access needed              │
│                                                  │
│ Returns:                                        │
│ "https://procstudio-bucket.s3.amazonaws.com/    │
│  development/team-31/offices/123/logo/          │
│  logo-20240115143022.png?                       │
│  X-Amz-Algorithm=AWS4-HMAC-SHA256&              │
│  X-Amz-Credential=...&                          │
│  X-Amz-Date=...&                                │
│  X-Amz-Expires=3600&                            │
│  X-Amz-Signature=..."                           │
└─────────────────────────────────────────────────┘
        │
        ▼
RESPONSE TO CLIENT
{
  "data": {
    "id": "123",
    "type": "office",
    "attributes": {
      "name": "Example Law Firm",
      "logo_url": "https://s3...presigned-url..."
    }
  }
}
        │
        ▼
CLIENT (Frontend)
<img src="{{ logo_url }}" />
        │
        ▼
Direct request to AWS S3 (no Rails server involved)
Downloads file if valid signature and not expired
```

### Presigned URL Benefits

✅ **Security**: Time-limited access, no public bucket
✅ **Performance**: Direct S3 access, no proxy through Rails
✅ **Scalability**: Offloads bandwidth from app servers
✅ **Flexibility**: Can set custom expiration times

---

## 7. CLASS RELATIONSHIPS DIAGRAM

```
┌──────────────────────────────────────────────────────────────┐
│                     CLASS HIERARCHY                           │
└──────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│   S3Service         │ ◄─── Singleton
│   (Class Methods)   │
├─────────────────────┤
│ + upload()          │
│ + delete()          │
│ + presigned_url()   │
│ + exists?()         │
│ + list_objects()    │
└──────────▲──────────┘
           │
           │ called by
           │
┌──────────┴──────────┐         ┌─────────────────────┐
│  S3Attachable       │         │  S3PathBuilder      │
│  (Module/Concern)   │         │  (Module/Concern)   │
├─────────────────────┤         ├─────────────────────┤
│                     │         │                     │
│ Classes:            │         │ Instance Methods:   │
│  ├─ BaseUploader    │         │  ├─ build_*_s3_key  │
│  ├─ LogoUploader    │────────►│  ├─ generate_*_url  │
│  ├─ AvatarUploader  │         │  └─ s3_prefix       │
│  ├─ SocialContract  │         │                     │
│  │   Uploader       │         │ Class Methods:      │
│  ├─ LogoDeleter     │         │  ├─ s3_prefix_for   │
│  ├─ AvatarDeleter   │         │  │   _team()         │
│  ├─ SocialContract  │         │  └─ build_s3_path() │
│  │   Deleter        │         │                     │
│  ├─ SocialContract  │         │ Helper Classes:     │
│  │   Presenter      │         │  ├─ WorkS3Key       │
│  └─ MetadataBuilder │         │  │   Builder         │
│                     │         │  └─ CustomerS3Key   │
│ Public Methods:     │         │     Builder         │
│  ├─ upload_logo()   │         └─────────────────────┘
│  ├─ upload_avatar() │                   ▲
│  ├─ logo_url()      │                   │
│  ├─ avatar_url()    │                   │ includes
│  └─ delete_*!()     │                   │
└─────────────────────┘                   │
           ▲                              │
           │ includes                     │
           │                              │
  ┌────────┴────────┐          ┌──────────┴──────────┐
  │     Office      │          │    UserProfile      │
  ├─────────────────┤          ├─────────────────────┤
  │ logo_s3_key     │          │ avatar_s3_key       │
  │ team_id         │          │ user_id             │
  │                 │          │                     │
  │ has_many        │          │ belongs_to :user    │
  │  :attachment_   │          │ belongs_to :office  │
  │   _metadata     │          └─────────────────────┘
  └─────────────────┘
           │
           │ has_many
           ▼
  ┌─────────────────────────────┐
  │ OfficeAttachmentMetadata    │
  ├─────────────────────────────┤
  │ s3_key (unique)             │
  │ filename                    │
  │ content_type                │
  │ byte_size                   │
  │ document_type               │
  │ uploaded_by_id              │
  │ custom_metadata (JSON)      │
  │                             │
  │ Scopes:                     │
  │  - social_contracts         │
  │  - logos                    │
  │                             │
  │ Methods:                    │
  │  - url()                    │
  │  - download_url()           │
  └─────────────────────────────┘
```

---

## 8. CONFIGURATION & INITIALIZATION

```
┌──────────────────────────────────────────────────────────────┐
│              ENVIRONMENT CONFIGURATION                        │
└──────────────────────────────────────────────────────────────┘

.env File
┌─────────────────────────────────────────────┐
│ AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE      │
│ AWS_SECRET_ACCESS_KEY=wJalr...              │
│ AWS_BUCKET_MAIN=procstudio-bucket           │
│ AWS_DEFAULT_REGION=us-west-2                │
└─────────────────────────────────────────────┘
                │
                │ loaded by
                ▼
┌─────────────────────────────────────────────┐
│    Dotenv (in development/test)             │
│  or Environment Variables (production)      │
└───────────────┬─────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────┐
│         S3Service Singleton                 │
│                                              │
│ Initialize on first access:                 │
│   @@s3_client = Aws::S3::Client.new(        │
│     region: ENV['AWS_DEFAULT_REGION'],      │
│     access_key_id: ENV[...],                │
│     secret_access_key: ENV[...]             │
│   )                                         │
│                                              │
│   @@presigner = Aws::S3::Presigner.new(     │
│     client: @@s3_client                     │
│   )                                         │
│                                              │
│   @@bucket = ENV['AWS_BUCKET_MAIN']         │
└─────────────────────────────────────────────┘
```

### Environment Variables Required

| Variable | Purpose | Example |
|----------|---------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_BUCKET_MAIN` | S3 bucket name | `procstudio-bucket` |
| `AWS_DEFAULT_REGION` | AWS region | `us-west-2` |

### Migration Status

```
┌──────────────────────────────────────────┐
│ ✅ Office logos → Direct S3              │
│ ✅ Office contracts → Direct S3          │
│ ✅ User avatars → Direct S3              │
│ ⚠️  Work documents → Partial (has keys)  │
│ ⚠️  Customer files → Partial (has keys)  │
│ ❌ Other attachments → ActiveStorage     │
└──────────────────────────────────────────┘
```

---

## 9. SECURITY & MULTI-TENANCY

### Team Isolation

```
User from Team 31          User from Team 42
      │                          │
      ├─ Can only access:        └─ Can only access:
      │  dev/team-31/*              dev/team-42/*
      │
      └─ Cannot access:
         dev/team-42/*
         (Enforced by team_id
          in path generation)
```

**How it works:**
- All S3 paths include `team-{team_id}` prefix
- `S3PathBuilder` extracts team_id from model associations
- No cross-team access possible through normal application flow
- Database constraints ensure team isolation

### Time-Limited Access

```
┌─────────────────────────────────────────────────┐
│  Presigned URL Lifecycle:                       │
│                                                  │
│  1. Generated: 2024-01-15 14:30:22              │
│  2. Expires:   2024-01-15 15:30:22 (1 hour)     │
│  3. After expiration → Access Denied            │
│                                                  │
│  Benefits:                                      │
│   - No public S3 bucket needed                  │
│   - URLs can't be shared long-term              │
│   - Automatic security through expiration       │
└─────────────────────────────────────────────────┘
```

**Customizable expiration:**
```ruby
# Short-lived (5 minutes for sensitive docs)
office.logo_url(expires_in: 300)

# Standard (1 hour - default)
office.logo_url(expires_in: 3600)

# Long-lived (24 hours for public sharing)
office.logo_url(expires_in: 86400)
```

### Environment Separation

```
development/    staging/       production/
  team-31/       team-31/       team-31/
    └─ Can be      └─ Isolated    └─ Strict
       cleaned         testing        controls
       freely          data           & backups
```

**Cleanup policies:**
- Development: Freely delete (cleanup scripts)
- Staging: Manual cleanup with confirmation
- Production: No automatic cleanup, audit logs required

### File Metadata Tracking

Every upload records:

| Field | Purpose | Example |
|-------|---------|---------|
| `uploaded_by_id` | Audit trail | User ID 76 |
| `created_at` | Upload timestamp | 2024-01-15 14:30:22 |
| `filename` | Original filename | `contract.pdf` |
| `content_type` | File MIME type | `application/pdf` |
| `byte_size` | File size | 524288 (512 KB) |
| `document_type` | Category | `social_contract` |
| `custom_metadata` | Extra data (JSON) | `{"version": "2.0"}` |

**Enables:**
- Audit trails for compliance
- Orphan file detection
- Usage analytics per team
- Compliance reporting (LGPD/GDPR)

---

## 10. KEY OBSERVATIONS & RECOMMENDATIONS

### ✅ STRENGTHS

#### 1. Clean Architecture
- Well-separated concerns (Service → Model → S3Service)
- Reusable modules (S3Attachable, S3PathBuilder)
- Single source of truth (S3Service singleton)
- Clear naming conventions

#### 2. Security First
- Team-based isolation in paths
- Presigned URLs (no public bucket)
- Metadata tracking for audits
- Environment separation (dev/staging/prod)

#### 3. Developer Experience
- Clear naming conventions
- Comprehensive test scripts
- Good error handling and logging
- Helpful rake tasks for cleanup
- Documentation with examples

#### 4. Scalability
- Supports millions of files per team
- Efficient S3 prefix queries
- Batch operations for cleanup
- Continuation token support for large buckets

### ⚠️ AREAS OF CONCERN

#### 1. Dual System Complexity

```
Current State:
- Office: Direct S3 ✅
- UserProfile: Direct S3 ✅
- Document: ActiveStorage + S3 keys ⚠️
- CustomerFile: ActiveStorage + S3 keys ⚠️

This creates:
- Two different upload patterns
- Maintenance burden
- Confusion for developers
- Performance overhead
```

#### 2. Inconsistent Storage Fields

- Some models: `logo_s3_key` (direct reference)
- Some models: `OfficeAttachmentMetadata` (indirect via join table)
- Some models: Still using ActiveStorage `blob_id`

**Recommendation:** Standardize on one approach

#### 3. Missing Features

- ❌ No virus scanning on uploads
- ❌ No image thumbnail generation
- ❌ No file deduplication
- ❌ No file versioning
- ❌ No orphan file cleanup automation

### 🔧 RECOMMENDATIONS

#### 1. Complete ActiveStorage Migration

**Priority Order:**

```ruby
1. Document model → Direct S3
   - Replace ActiveStorage attachments
   - Use S3PathBuilder for work documents
   - Migrate existing blobs to S3 structure

2. CustomerFile model → Direct S3
   - Replace ActiveStorage attachments
   - Use S3PathBuilder for customer docs
   - Migrate existing customer files

3. Other models using ActiveStorage
   - Audit remaining ActiveStorage usage
   - Plan migration strategy
   - Execute migration with rollback plan
```

**Benefits:**
- Single upload pattern across app
- Reduced dependencies (remove ActiveStorage gem)
- Better performance (direct S3, no blob table queries)
- Clearer codebase

#### 2. Implement Phase 2 Features (from docs)

```ruby
# app/models/stored_file.rb
class StoredFile < ApplicationRecord
  # Centralized file storage with deduplication
  # Uses SHA256 hash for uniqueness
  # Polymorphic references via FileReference

  has_many :file_references, dependent: :destroy

  validates :sha256_hash, presence: true, uniqueness: true
  validates :s3_key, presence: true, uniqueness: true

  before_validation :calculate_hash

  def self.find_or_create_from_file(file)
    hash = Digest::SHA256.hexdigest(file.read)
    file.rewind

    find_or_create_by(sha256_hash: hash) do |stored_file|
      # Upload only if new
      stored_file.s3_key = upload_to_s3(file, hash)
      stored_file.byte_size = file.size
      stored_file.content_type = file.content_type
    end
  end
end

# app/models/file_reference.rb
class FileReference < ApplicationRecord
  belongs_to :stored_file
  belongs_to :referenceable, polymorphic: true

  # Metadata specific to this reference
  # (filename, description, uploaded_by_id, etc.)
end
```

**Benefits:**
- Deduplication saves storage costs
- Single source of truth for file data
- Easy to track file usage across models
- Simplified deletion logic

#### 3. Add File Processing Pipeline

```ruby
# app/services/file_processors/
class VirusScanProcessor
  # Integrate ClamAV or AWS GuardDuty
  def self.scan(file)
    # Scan for viruses before S3 upload
    # Return true if clean, false if infected
  end
end

class ImageThumbnailProcessor
  # Use ImageMagick or Vips
  def self.generate(image_s3_key)
    # Generate thumbnails: small, medium, large
    # Store in S3 with naming convention
  end
end

class DocumentPreviewProcessor
  # PDF generation for DOCX files
  def self.generate_preview(docx_s3_key)
    # Convert DOCX to PDF preview
    # Store PDF in S3
  end
end

class MetadataExtractorProcessor
  # Extract EXIF, file info
  def self.extract(file)
    # Return hash of metadata
    # Store in custom_metadata JSON
  end
end
```

**Usage:**
```ruby
# In uploader
def upload
  return false unless VirusScanProcessor.scan(@file)

  s3_key = perform_upload

  # Background jobs for processing
  ImageThumbnailProcessor.perform_later(s3_key) if image?
  DocumentPreviewProcessor.perform_later(s3_key) if docx?

  s3_key
end
```

#### 4. Consolidate Metadata Storage

**Current inconsistency:**
- Logos: Direct column (`logo_s3_key`)
- Social contracts: Metadata table (`OfficeAttachmentMetadata`)

**Option A: Always use metadata table** (Recommended for flexibility)

```ruby
# Consistent for all file types
class Office
  has_many :attachments, class_name: 'FileAttachment', as: :attachable

  def logo
    attachments.logos.first
  end

  def logo_url
    logo&.presigned_url
  end
end

# Benefits:
# - Consistent query patterns
# - Flexible metadata
# - Easy to add new file types
# - Better for multiple files
```

**Option B: Always use direct column** (Better for performance)

```ruby
# One column per file type
class Office
  # logo_s3_key
  # social_contract_s3_key (store latest)
end

# Benefits:
# - Simpler queries (no joins)
# - Better performance
# - Clearer schema
# - Better for single files
```

**Recommendation:** Use **metadata table** for scalability and flexibility

#### 5. Add Background Jobs for Large Files

```ruby
# app/jobs/process_upload_job.rb
class ProcessUploadJob < ApplicationJob
  queue_as :uploads

  def perform(file_params, model_type, model_id, user_id)
    # 1. Validate file
    # 2. Scan for viruses
    # 3. Upload to S3
    # 4. Generate thumbnails/previews
    # 5. Extract metadata
    # 6. Update database
    # 7. Send notification to user
  rescue => e
    # Log error
    # Notify user of failure
    # Clean up partial uploads
  end
end

# Usage in controller:
ProcessUploadJob.perform_later(
  file_params: params[:file],
  model_type: 'Office',
  model_id: @office.id,
  user_id: current_user.id
)
```

**Benefits:**
- Non-blocking uploads for large files
- Better error recovery
- Progress tracking
- Resource management

#### 6. Improve Error Handling

**Current:** Silent failures in some cases
**Better:** Structured error responses

```ruby
# app/errors/s3_errors.rb
class S3Error < StandardError; end
class S3UploadError < S3Error; end
class S3DeleteError < S3Error; end
class S3AccessError < S3Error; end

# In S3Service:
def upload(file, s3_key, metadata = {})
  # ... upload logic
rescue Aws::S3::Errors::ServiceError => e
  Rails.logger.error("S3 upload failed: #{e.message}")
  Sentry.capture_exception(e) if defined?(Sentry)
  raise S3UploadError, "Failed to upload file: #{e.message}"
end

# In controller:
rescue S3UploadError => e
  render json: {
    success: false,
    error: 'upload_failed',
    message: 'File upload failed. Please try again.',
    details: Rails.env.development? ? e.message : nil
  }, status: :unprocessable_entity
```

**Use Sentry or Bugsnag for error tracking:**
```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environment = Rails.env
  config.enabled_environments = %w[production staging]

  # Filter sensitive data
  config.before_send = lambda do |event, hint|
    event.request.data.delete(:AWS_SECRET_ACCESS_KEY)
    event
  end
end
```

#### 7. Add Monitoring & Metrics

**Track:**
- Upload success/failure rates
- Average upload time
- Storage usage per team
- Presigned URL generation rate
- Failed deletions
- Orphaned files

**Implementation:**

```ruby
# app/services/s3_metrics_service.rb
class S3MetricsService
  def self.track_upload(s3_key:, duration:, success:, team_id:)
    StatsD.increment('s3.upload.total', tags: ["team:#{team_id}"])
    StatsD.increment('s3.upload.success', tags: ["team:#{team_id}"]) if success
    StatsD.histogram('s3.upload.duration', duration, tags: ["team:#{team_id}"])

    # Or use custom metrics table
    S3Metric.create!(
      metric_type: 'upload',
      team_id: team_id,
      s3_key: s3_key,
      duration_ms: duration,
      success: success,
      timestamp: Time.current
    )
  end
end

# In S3Service:
def upload(file, s3_key, metadata = {})
  start_time = Time.current
  result = perform_upload(file, s3_key, metadata)
  duration = ((Time.current - start_time) * 1000).to_i

  S3MetricsService.track_upload(
    s3_key: s3_key,
    duration: duration,
    success: true,
    team_id: extract_team_id(s3_key)
  )

  result
rescue => e
  S3MetricsService.track_upload(
    s3_key: s3_key,
    duration: ((Time.current - start_time) * 1000).to_i,
    success: false,
    team_id: extract_team_id(s3_key)
  )
  raise
end
```

**Dashboard queries:**
```sql
-- Daily upload success rate
SELECT
  DATE(timestamp) as date,
  COUNT(*) as total_uploads,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful,
  AVG(duration_ms) as avg_duration_ms
FROM s3_metrics
WHERE metric_type = 'upload'
  AND timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date DESC;

-- Storage by team
SELECT
  team_id,
  COUNT(*) as file_count,
  SUM(byte_size) / 1024 / 1024 as storage_mb
FROM office_attachment_metadata
GROUP BY team_id
ORDER BY storage_mb DESC;
```

**Tools:**
- DataDog / NewRelic for APM
- CloudWatch for S3 metrics
- Grafana for custom dashboards
- PgHero for database insights

---

## 11. TESTING UTILITIES

### Available Test Scripts

```
rails_runner_tests/
├── test_s3_env.rb              # Quick environment check
├── test_s3_diagnose.rb         # Comprehensive diagnostic
├── test_s3_phase1.rb           # Full Phase 1 test
└── (your integration tests)
```

### 1. Quick Environment Check

```bash
rails runner rails_runner_tests/test_s3_env.rb
```

**What it does:**
- Loads dotenv
- Checks all S3 environment variables
- Tests S3 connection
- Reports configuration status

**Output:**
```
✅ AWS_ACCESS_KEY_ID: AKIAIOSFODNN...
✅ AWS_SECRET_ACCESS_KEY: ********
✅ AWS_BUCKET_MAIN: procstudio-bucket
✅ AWS_DEFAULT_REGION: us-west-2
✅ S3 appears to be configured
   Status: Connected successfully! ✅
```

### 2. Comprehensive Diagnostic

```bash
rails runner rails_runner_tests/test_s3_diagnose.rb
```

**What it does:**
- Checks raw environment before dotenv
- Loads dotenv and checks again
- Tests Office model S3 configuration
- Creates S3 client
- Tests bucket access
- Determines storage mode (S3 vs local)

**Use when:** Debugging configuration issues

### 3. Full Phase 1 Implementation Test

```bash
rails runner rails_runner_tests/test_s3_phase1.rb
```

**What it does:**
- Tests S3Service availability
- Tests S3PathBuilder path generation
- Tests S3Attachable methods
- Validates database columns
- Simulates actual file upload (optional)
- Tests URL generation
- Tests file deletion

**Use when:** Verifying complete S3 implementation

### 4. Cleanup Scripts

#### Rake Tasks

```bash
# List all development files
rails s3:cleanup:list

# Clean all development files
rails s3:cleanup:development

# Clean specific team files
rails s3:cleanup:team[31]
```

**Features:**
- Development-only (production safeguard)
- Requires 'DELETE' confirmation
- Batch deletion (1000 per batch)
- Statistics (file count, total size)

#### Standalone Script

```bash
# List files
ruby scripts/s3_cleanup.rb list
ruby scripts/s3_cleanup.rb list 31

# Delete files
ruby scripts/s3_cleanup.rb development
ruby scripts/s3_cleanup.rb development 31

# Help
ruby scripts/s3_cleanup.rb help
```

**Benefits:**
- Works without Rails
- Uses Dotenv for credentials
- Team-based statistics
- Interactive confirmation

---

## 12. COMPONENT REFERENCE

### S3Service Methods

| Method | Purpose | Parameters | Returns |
|--------|---------|-----------|---------|
| `upload(file, s3_key, metadata)` | Upload file to S3 | file, s3_key, metadata hash | boolean |
| `delete(s3_key)` | Delete file from S3 | s3_key | boolean |
| `exists?(s3_key)` | Check if file exists | s3_key | boolean |
| `presigned_url(s3_key, expires_in)` | Generate view URL | s3_key, seconds | string (URL) |
| `presigned_download_url(s3_key, filename, expires_in)` | Generate download URL | s3_key, filename, seconds | string (URL) |
| `presigned_upload_url(s3_key, content_type, expires_in)` | Generate client upload URL | s3_key, type, seconds | string (URL) |
| `copy(source, destination)` | Copy file within S3 | source_key, dest_key | boolean |
| `list_objects(prefix, max_keys)` | List files by prefix | prefix, limit | array |
| `get_object_metadata(s3_key)` | Get file metadata | s3_key | hash |
| `download(s3_key)` | Download file content | s3_key | string (content) |

### S3PathBuilder Methods

**Instance Methods:**

| Method | Returns | Example |
|--------|---------|---------|
| `build_logo_s3_key(ext)` | Logo path | `dev/team-31/offices/123/logo/logo-20240115.png` |
| `build_avatar_s3_key(ext)` | Avatar path | `dev/team-31/users/456/avatar/avatar-20240115.jpg` |
| `build_social_contract_s3_key(ext)` | Contract path | `dev/team-31/offices/123/social-contracts/contract-20240115-a3f2d1.pdf` |
| `build_work_document_s3_key(type, ext)` | Work doc path | `dev/team-31/works/789/documents/procuration/doc-20240115.docx` |
| `generate_presigned_url(s3_key, expires_in)` | Presigned URL | `https://s3.amazonaws.com/...` |

**Class Methods:**

| Method | Returns | Example |
|--------|---------|---------|
| `s3_prefix_for_team(team_id)` | Team prefix | `development/team-31` |
| `build_s3_path(team_id, components)` | Custom path | `dev/team-31/custom/path.ext` |

### S3Attachable Methods

**Upload:**
- `upload_logo(file, metadata)` → boolean
- `upload_avatar(file, metadata)` → boolean
- `upload_social_contract(file, metadata)` → boolean

**URL Generation:**
- `logo_url(expires_in: 3600)` → string
- `avatar_url(expires_in: 3600)` → string
- `social_contracts_with_urls(expires_in: 3600)` → array[hash]
- `social_contracts_with_metadata(expires_in: 3600)` → array[hash]

**Deletion:**
- `delete_logo!` → boolean
- `delete_avatar!` → boolean
- `delete_social_contract!(attachment_id)` → boolean

### OfficeAttachmentMetadata

**Schema:**
```ruby
create_table :office_attachment_metadata do |t|
  t.references :office, null: false, foreign_key: true
  t.string :s3_key, null: false, index: { unique: true }
  t.string :filename, null: false
  t.string :content_type, null: false
  t.bigint :byte_size, null: false
  t.string :document_type, null: false
  t.bigint :uploaded_by_id
  t.date :document_date
  t.text :description
  t.json :custom_metadata
  t.timestamps
end
```

**Scopes:**
- `social_contracts` → where(document_type: 'social_contract')
- `logos` → where(document_type: 'logo')

**Methods:**
- `url(expires_in: 3600)` → Presigned URL
- `download_url(expires_in: 3600)` → Presigned download URL

---

## Summary

Your S3 implementation is **well-architected** with:

### ✅ Strengths
- Clean separation of concerns
- Team-based multi-tenancy
- Security-first approach (presigned URLs, team isolation)
- Good test coverage
- Comprehensive documentation

### ⚠️ Current State
- **Office & UserProfile**: Fully migrated ✓
- **Document & CustomerFile**: Partial migration (dual system)
- **Other models**: Still on ActiveStorage

### 🚀 Recommended Next Steps

1. **Complete ActiveStorage Migration**
   - Migrate Document model to direct S3
   - Migrate CustomerFile model to direct S3
   - Remove ActiveStorage dependency

2. **Implement Phase 2**
   - Add StoredFile model for deduplication
   - Add FileReference for polymorphic associations
   - Reduce storage costs through deduplication

3. **Add File Processing**
   - Virus scanning (ClamAV/AWS GuardDuty)
   - Image thumbnails (ImageMagick/Vips)
   - Document previews (PDF generation)
   - Metadata extraction (EXIF)

4. **Enhance Monitoring**
   - Upload success/failure metrics
   - Storage usage per team
   - Performance monitoring
   - Custom dashboards

5. **Improve Error Handling**
   - Structured error classes
   - Better error messages
   - Sentry/Bugsnag integration
   - Automatic retry logic

The foundation is solid and production-ready. The main work ahead is completing the migration and adding the planned enhancements.

---

**Last Updated:** 2024-11-16
**Next Review:** After Phase 2 implementation
