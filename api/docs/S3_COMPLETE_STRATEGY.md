# S3 Complete Implementation Strategy

**Date:** 2025-11-16
**Branch:** s3_improvements
**Status:** Implementation Plan

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Target Architecture](#target-architecture)
4. [Implementation Strategy](#implementation-strategy)
5. [Phase 1: Unified Metadata Layer](#phase-1-unified-metadata-layer)
6. [Phase 2: Centralized S3Manager](#phase-2-centralized-s3manager)
7. [Phase 3: ActiveStorage Removal](#phase-3-activestorage-removal)
8. [Phase 4: Enhanced Features](#phase-4-enhanced-features)
9. [Migration Path](#migration-path)
10. [API Specifications](#api-specifications)

---

## Executive Summary

ProcStudio's S3 implementation is transitioning from ActiveStorage to a custom S3 solution. This document outlines a complete strategy to:

- **Unify** file metadata tracking across all models
- **Centralize** S3 operations through a single service
- **Track** system-generated vs user-uploaded files
- **Optimize** file listing and searching performance
- **Enable** seamless file movement between models
- **Complete** the ActiveStorage migration

### Key Decisions

1. **Database-driven metadata** instead of S3 tags for performance
2. **Single FileMetadata model** for all file tracking
3. **Singleton S3Manager** as the sole interface to S3
4. **Temporary upload pool** for undesignated files
5. **System flag** in database rather than separate folders
6. **UserProfile-based attachments** instead of User model for all files
7. **BREAKING CHANGES APPROACH** - Complete replacement without backward compatibility

---

## Current State Analysis

### Problems Identified

1. **Hybrid Storage** - Models use BOTH ActiveStorage and S3 keys
2. **Inconsistent Metadata** - Some files tracked in columns, others in separate table
3. **No System Tracking** - Cannot distinguish system-generated from user uploads
4. **Poor Performance** - S3 listing is slow, no database indexing
5. **Limited Search** - No filtering by date, user, type, or metadata
6. **Complex Code** - Multiple patterns (S3Attachable vs direct S3Service)
7. **Memory Issues** - Downloads load entire file into memory
8. **No File Movement** - Cannot move files between models easily

### Current Architecture

```
Models → S3Attachable Concern → S3Service → AWS S3
     ↘                        ↗
      ActiveStorage (parallel)
```

### File Storage Patterns

| Model | S3 Implementation | ActiveStorage | Metadata |
|-------|-------------------|---------------|----------|
| Office | logo_s3_key column | No | OfficeAttachmentMetadata for contracts |
| UserProfile | avatar_s3_key column | has_one_attached :avatar | None |
| Document | original_s3_key, signed_s3_key | has_one_attached :original, :signed | None |
| CustomerFile | file_s3_key | has_one_attached :file | None |
| Job | attachment_s3_key | has_one_attached :attachment | None |
| Work | document_s3_keys (JSON) | multiple attachments | None |

---

## Target Architecture

### Simplified Flow

```
All Models → S3Manager (Singleton) → S3Service → AWS S3
                    ↓
             FileMetadata (Database)
```

### Core Components

#### 1. FileMetadata Model (Universal)
```ruby
class FileMetadata < ApplicationRecord
  # Polymorphic association to any model
  belongs_to :attachable, polymorphic: true
  belongs_to :uploaded_by, class_name: 'UserProfile', optional: true

  # Core tracking fields
  # - s3_key: string (unique, indexed)
  # - filename: string
  # - content_type: string
  # - byte_size: bigint
  # - checksum: string (SHA256, for deduplication)
  # - created_by_system: boolean (tracks system vs user files)
  # - file_category: string (logo, avatar, social_contract, job_attachment, work_document, etc.)
  # - metadata: jsonb (flexible key-value storage)
  # - uploaded_at: datetime
  # - expires_at: datetime (for temporary files)

  # Scopes for filtering
  scope :system_generated, -> { where(created_by_system: true) }
  scope :user_uploaded, -> { where(created_by_system: false) }
  scope :by_category, ->(cat) { where(file_category: cat) }
  scope :temporary, -> { where.not(expires_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }

  # Helper method to get User from UserProfile
  def user
    uploaded_by&.user
  end
end
```

#### 2. S3Manager Service (Singleton)
```ruby
class S3Manager
  include Singleton

  class << self
    delegate :upload, :download, :delete, :move, :copy, :list, :url, to: :instance
  end

  # Smart upload with metadata tracking
  def upload(file, model: nil, path: nil, system_generated: false, metadata: {})
    # Generate path if not provided
    s3_key = path || PathGenerator.for(model)

    # Check for duplicates via checksum
    checksum = calculate_checksum(file)
    existing = FileMetadata.find_by(checksum: checksum, attachable: model)
    return existing if existing && !metadata[:force_upload]

    # Upload to S3
    S3Service.upload(file, s3_key, build_s3_metadata(metadata))

    # Track in database
    FileMetadata.create!(
      attachable: model,
      s3_key: s3_key,
      filename: extract_filename(file),
      content_type: extract_content_type(file),
      byte_size: file.size,
      checksum: checksum,
      created_by_system: system_generated,
      uploaded_by: metadata[:current_user_profile],
      file_category: detect_category(model, s3_key),
      metadata: metadata.except(:current_user_profile, :force_upload),
      uploaded_at: Time.current
    )
  end

  # Move file between models
  def move(file_metadata, to_model)
    old_key = file_metadata.s3_key
    new_key = PathGenerator.for(to_model)

    # Copy in S3
    S3Service.copy(old_key, new_key)

    # Update metadata
    file_metadata.update!(
      attachable: to_model,
      s3_key: new_key,
      file_category: detect_category(to_model, new_key)
    )

    # Delete old file
    S3Service.delete(old_key)

    file_metadata
  end

  # Fast listing from database
  def list(team_id, filters = {})
    query = FileMetadata.joins(build_team_join)
                        .where(build_team_condition(team_id))

    # Apply filters
    query = query.system_generated if filters[:system_only]
    query = query.user_uploaded if filters[:user_only]
    query = query.by_category(filters[:category]) if filters[:category]
    query = query.where(uploaded_by_id: filters[:user_id]) if filters[:user_id]
    query = query.where('uploaded_at >= ?', filters[:from_date]) if filters[:from_date]
    query = query.where('uploaded_at <= ?', filters[:to_date]) if filters[:to_date]

    query.includes(:uploaded_by, :attachable)
  end

  # Generate presigned URLs
  def url(file_metadata, type: :view, expires_in: 3600)
    case type
    when :view
      S3Service.presigned_url(file_metadata.s3_key, expires_in: expires_in)
    when :download
      S3Service.presigned_download_url(
        file_metadata.s3_key,
        file_metadata.filename,
        expires_in: expires_in
      )
    when :upload
      S3Service.presigned_upload_url(
        file_metadata.s3_key,
        content_type: file_metadata.content_type,
        expires_in: expires_in
      )
    end
  end

  # Stream download (memory efficient)
  def download_stream(file_metadata, &block)
    S3Service.download_stream(file_metadata.s3_key, &block)
  end
end
```

#### 3. PathGenerator Module
```ruby
module PathGenerator
  extend self

  def for(model, options = {})
    case model
    when Office
      office_path(model, options)
    when UserProfile
      user_profile_path(model, options)
    when Job
      job_path(model, options)
    when Work
      work_path(model, options)
    when TempUpload
      temp_path(model, options)
    else
      raise UnsupportedModelError, "No path generator for #{model.class}"
    end
  end

  private

  def office_path(office, options = {})
    type = options[:file_type] || 'logo'
    ext = options[:extension] || 'jpg'

    case type
    when 'logo'
      "#{base_prefix(office.team_id)}/offices/#{office.id}/logo/logo-#{timestamp}.#{ext}"
    when 'social_contract'
      "#{base_prefix(office.team_id)}/offices/#{office.id}/social-contracts/contract-#{timestamp}-#{random_hash}.#{ext}"
    end
  end

  def user_profile_path(profile, options = {})
    team_id = extract_team_id(profile)
    ext = options[:extension] || 'jpg'

    "#{base_prefix(team_id)}/user-profiles/#{profile.id}/avatar/avatar-#{timestamp}.#{ext}"
  end

  def job_path(job, options = {})
    team_id = extract_team_id(job)
    type = options[:file_type] || 'attachment'
    ext = options[:extension] || 'pdf'

    "#{base_prefix(team_id)}/jobs/#{job.id}/#{type}/#{type}-#{timestamp}-#{random_hash}.#{ext}"
  end

  def work_path(work, options = {})
    team_id = extract_team_id(work)
    type = options[:file_type] || 'document'
    ext = options[:extension] || 'pdf'

    "#{base_prefix(team_id)}/works/#{work.id}/#{type}/#{type}-#{timestamp}-#{random_hash}.#{ext}"
  end

  def temp_path(temp_upload, options = {})
    "#{base_prefix(temp_upload.team_id)}/temp-uploads/#{temp_upload.user_profile_id}/#{timestamp}-#{temp_upload.original_filename}"
  end

  def base_prefix(team_id)
    "#{Rails.env}/team-#{team_id}"
  end

  def timestamp
    Time.current.strftime('%Y%m%d%H%M%S')
  end

  def random_hash
    SecureRandom.hex(6)
  end

  def extract_team_id(model)
    # Smart team extraction with validation
    team_id = case model
              when Office then model.team_id
              when UserProfile then model.user&.current_team&.id || model.office&.team_id
              when Job then model.team_id || model.office&.team_id
              when Work then model.team_id || model.job&.team_id
              end

    raise TeamNotFoundError, "Cannot determine team for #{model.class}" if team_id.nil?
    team_id
  end
end
```

#### 4. TempUpload Model (For Undesignated Files)
```ruby
class TempUpload < ApplicationRecord
  belongs_to :user_profile
  belongs_to :team

  # Fields:
  # - s3_key: string
  # - original_filename: string
  # - content_type: string
  # - byte_size: bigint
  # - expires_at: datetime (default: 7.days.from_now)
  # - metadata: jsonb

  scope :expired, -> { where('expires_at < ?', Time.current) }

  # Helper method to get User
  def user
    user_profile&.user
  end

  # Attach temporary file to a model
  def attach_to(model, as: :attachment)
    file_metadata = FileMetadata.find_by(s3_key: s3_key)

    S3Manager.move(file_metadata, model)

    # Clean up temp record
    destroy
  end

  # Create from upload
  def self.create_from_upload(file, user_profile:, team:)
    s3_key = PathGenerator.for_temp(user_profile, team, file.original_filename)

    S3Service.upload(file, s3_key)

    create!(
      user_profile: user_profile,
      team: team,
      s3_key: s3_key,
      original_filename: file.original_filename,
      content_type: file.content_type,
      byte_size: file.size,
      expires_at: 7.days.from_now
    )
  end
end
```

---

## Implementation Strategy

### Guiding Principles

1. **BREAKING CHANGES** - Complete replacement without backward compatibility
2. **Direct Migration** - Remove ActiveStorage and old patterns immediately
3. **Data Integrity** - Migrate all existing files to new system
4. **Performance First** - Database queries over S3 operations
5. **Clean Architecture** - Single responsibility, clear interfaces

### Development Approach

1. **Complete Replacement** - Remove old system entirely
2. **Single Implementation** - No feature flags or dual systems
3. **Comprehensive Testing** - Unit, integration, and new system tests
4. **Fresh Start** - Clean slate implementation
5. **No Rollback** - Development environment allows full replacement

---

## Phase 1: Unified Metadata Layer

### 1.1 Create FileMetadata Model

```bash
rails generate model FileMetadata \
  attachable:references{polymorphic} \
  s3_key:string:uniq \
  filename:string \
  content_type:string \
  byte_size:bigint \
  checksum:string:index \
  created_by_system:boolean:index \
  file_category:string:index \
  uploaded_by:references \
  metadata:jsonb \
  uploaded_at:datetime:index \
  expires_at:datetime:index
```

### 1.2 Migration File
```ruby
class CreateFileMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :file_metadata do |t|
      t.references :attachable, polymorphic: true, null: false, index: true
      t.string :s3_key, null: false
      t.string :filename, null: false
      t.string :content_type, null: false
      t.bigint :byte_size, null: false
      t.string :checksum, null: false
      t.boolean :created_by_system, default: false, null: false
      t.string :file_category
      t.references :uploaded_by, foreign_key: { to_table: :user_profiles }
      t.jsonb :metadata, default: {}
      t.datetime :uploaded_at, null: false
      t.datetime :expires_at

      t.timestamps

      t.index :s3_key, unique: true
      t.index :checksum
      t.index :created_by_system
      t.index :file_category
      t.index :uploaded_at
      t.index :expires_at
      t.index [:attachable_type, :attachable_id, :file_category],
              name: 'index_file_metadata_on_attachable_and_category'
    end
  end
end
```

### 1.3 Model Implementation
```ruby
# app/models/file_metadata.rb
class FileMetadata < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :uploaded_by, class_name: 'UserProfile', optional: true

  validates :s3_key, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :byte_size, presence: true, numericality: { greater_than: 0 }
  validates :checksum, presence: true
  validates :file_category, inclusion: { in: FILE_CATEGORIES }, allow_nil: true

  FILE_CATEGORIES = %w[
    logo avatar social_contract
    job_attachment work_document
    procuration waiver deficiency_statement honorary
    customer_document temp_upload
  ].freeze

  scope :system_generated, -> { where(created_by_system: true) }
  scope :user_uploaded, -> { where(created_by_system: false) }
  scope :by_category, ->(category) { where(file_category: category) }
  scope :temporary, -> { where.not(expires_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :permanent, -> { where(expires_at: nil) }

  def url(type: :view, expires_in: 3600)
    S3Manager.url(self, type: type, expires_in: expires_in)
  end

  def system_generated?
    created_by_system
  end

  def user_uploaded?
    !created_by_system
  end

  def temporary?
    expires_at.present?
  end

  def expired?
    temporary? && expires_at < Time.current
  end

  # Helper method to get User from UserProfile
  def user
    uploaded_by&.user
  end
end
```

### 1.4 Direct Data Transfer

Since we're doing a complete replacement in development, existing data will be transferred directly to the new system when the models are updated. No incremental migration is needed.

---

## Phase 2: Centralized S3Manager

### 2.1 Create S3Manager Service

```ruby
# app/services/s3_manager.rb
class S3Manager
  include Singleton

  class FileNotFoundError < StandardError; end
  class UploadError < StandardError; end
  class TeamNotFoundError < StandardError; end

  class << self
    delegate :upload, :download, :delete, :move, :copy, :list, :url, :stream, to: :instance
  end

  def upload(file, model: nil, path: nil, system_generated: false, user_profile: nil, metadata: {})
    raise ArgumentError, "Either model or path must be provided" unless model || path

    # Generate path
    s3_key = path || PathGenerator.for(model, metadata)

    # Calculate checksum for deduplication
    checksum = calculate_checksum(file)

    # Check for existing file with same checksum
    if model && (existing = FileMetadata.find_by(attachable: model, checksum: checksum))
      return existing unless metadata[:force_new]
    end

    # Upload to S3
    begin
      S3Service.upload(file, s3_key, build_s3_metadata(model, user_profile, metadata))
    rescue => e
      Rails.logger.error "S3 upload failed: #{e.message}"
      raise UploadError, "Failed to upload file: #{e.message}"
    end

    # Create metadata record
    FileMetadata.create!(
      attachable: model,
      s3_key: s3_key,
      filename: extract_filename(file),
      content_type: extract_content_type(file),
      byte_size: extract_file_size(file),
      checksum: checksum,
      created_by_system: system_generated,
      uploaded_by: user_profile,
      file_category: detect_category(model, s3_key),
      metadata: metadata,
      uploaded_at: Time.current,
      expires_at: metadata[:expires_at]
    )
  rescue ActiveRecord::RecordInvalid => e
    # Rollback S3 upload if metadata creation fails
    S3Service.delete(s3_key) rescue nil
    raise e
  end

  def delete(file_metadata)
    return false unless file_metadata

    # Delete from S3 first
    S3Service.delete(file_metadata.s3_key)

    # Then delete metadata
    file_metadata.destroy
    true
  rescue => e
    Rails.logger.error "Failed to delete file: #{e.message}"
    false
  end

  def move(file_metadata, to_model, options = {})
    raise FileNotFoundError, "File metadata not found" unless file_metadata

    old_key = file_metadata.s3_key
    new_key = PathGenerator.for(to_model, options)

    # Copy in S3
    S3Service.copy(old_key, new_key)

    # Update metadata atomically
    file_metadata.with_lock do
      file_metadata.update!(
        attachable: to_model,
        s3_key: new_key,
        file_category: detect_category(to_model, new_key)
      )
    end

    # Delete old file only after successful update
    S3Service.delete(old_key)

    file_metadata
  rescue => e
    # Rollback: delete new file if it was created
    S3Service.delete(new_key) rescue nil
    raise e
  end

  def copy(file_metadata, to_model, options = {})
    raise FileNotFoundError, "File metadata not found" unless file_metadata

    new_key = PathGenerator.for(to_model, options)

    # Copy in S3
    S3Service.copy(file_metadata.s3_key, new_key)

    # Create new metadata record
    FileMetadata.create!(
      file_metadata.attributes.except('id', 'created_at', 'updated_at').merge(
        attachable: to_model,
        s3_key: new_key,
        file_category: detect_category(to_model, new_key),
        uploaded_at: Time.current
      )
    )
  end

  def list(scope, filters = {})
    query = case scope
            when Integer # Team ID
              list_by_team(scope)
            when ActiveRecord::Base # Model instance
              FileMetadata.where(attachable: scope)
            else
              FileMetadata.all
            end

    # Apply filters
    query = apply_filters(query, filters)

    # Pagination
    query = query.page(filters[:page]).per(filters[:per_page] || 25) if filters[:page]

    query.includes(:uploaded_by, :attachable)
  end

  def url(file_metadata, type: :view, expires_in: 3600)
    return nil unless file_metadata&.s3_key

    case type
    when :view
      S3Service.presigned_url(file_metadata.s3_key, expires_in: expires_in)
    when :download
      S3Service.presigned_download_url(
        file_metadata.s3_key,
        file_metadata.filename,
        expires_in: expires_in
      )
    when :upload
      S3Service.presigned_upload_url(
        file_metadata.s3_key,
        content_type: file_metadata.content_type,
        expires_in: expires_in
      )
    else
      raise ArgumentError, "Unknown URL type: #{type}"
    end
  end

  def stream(file_metadata, &block)
    raise FileNotFoundError, "File metadata not found" unless file_metadata

    S3Service.download_stream(file_metadata.s3_key, &block)
  end

  private

  def calculate_checksum(file)
    if file.respond_to?(:path)
      Digest::SHA256.file(file.path).hexdigest
    elsif file.respond_to?(:read)
      content = file.read
      file.rewind if file.respond_to?(:rewind)
      Digest::SHA256.hexdigest(content)
    else
      Digest::SHA256.hexdigest(file.to_s)
    end
  end

  def extract_filename(file)
    if file.respond_to?(:original_filename)
      file.original_filename
    elsif file.respond_to?(:path)
      File.basename(file.path)
    else
      'unknown'
    end
  end

  def extract_content_type(file)
    if file.respond_to?(:content_type)
      file.content_type
    elsif file.respond_to?(:path)
      Marcel::MimeType.for(Pathname.new(file.path))
    else
      'application/octet-stream'
    end
  end

  def extract_file_size(file)
    if file.respond_to?(:size)
      file.size
    elsif file.respond_to?(:path)
      File.size(file.path)
    else
      0
    end
  end

  def detect_category(model, s3_key)
    return nil unless model

    case model
    when Office
      s3_key.include?('/logo/') ? 'logo' : 'social_contract'
    when UserProfile
      'avatar'
    when Job
      'job_attachment'
    when Work
      detect_work_document_type(s3_key) || 'work_document'
    when TempUpload
      'temp_upload'
    else
      model.class.name.underscore
    end
  end

  def detect_work_document_type(s3_key)
    %w[procuration waiver deficiency_statement honorary].find do |type|
      s3_key.include?("/#{type}/")
    end
  end

  def build_s3_metadata(model, user_profile, custom_metadata)
    metadata = {
      'uploaded-by-profile' => user_profile&.id&.to_s,
      'uploaded-by-user' => user_profile&.user&.id&.to_s,
      'uploaded-at' => Time.current.iso8601,
      'model-type' => model&.class&.name,
      'model-id' => model&.id&.to_s
    }

    # Add custom metadata
    custom_metadata.each do |key, value|
      metadata["custom-#{key}"] = value.to_s
    end

    metadata
  end

  def list_by_team(team_id)
    # Simplified approach using subqueries for better readability
    office_ids = Office.where(team_id: team_id).pluck(:id)
    user_profile_ids = UserProfile.joins(:user)
                                   .where(users: { current_team_id: team_id })
                                   .or(UserProfile.where(office_id: office_ids))
                                   .pluck(:id)
    job_ids = Job.where(team_id: team_id)
                 .or(Job.where(office_id: office_ids))
                 .pluck(:id)
    work_ids = Work.joins(:job)
                   .where(jobs: { team_id: team_id })
                   .pluck(:id)

    FileMetadata.where(
      attachable_type: 'Office', attachable_id: office_ids
    ).or(
      FileMetadata.where(attachable_type: 'UserProfile', attachable_id: user_profile_ids)
    ).or(
      FileMetadata.where(attachable_type: 'Job', attachable_id: job_ids)
    ).or(
      FileMetadata.where(attachable_type: 'Work', attachable_id: work_ids)
    ).or(
      FileMetadata.where(attachable_type: 'TempUpload')
                  .joins("INNER JOIN temp_uploads ON attachable_id = temp_uploads.id")
                  .where(temp_uploads: { team_id: team_id })
    )
  end

  def apply_filters(query, filters)
    query = query.system_generated if filters[:system_only]
    query = query.user_uploaded if filters[:user_only]
    query = query.by_category(filters[:category]) if filters[:category]
    query = query.where(uploaded_by_id: filters[:user_id]) if filters[:user_id]
    query = query.where('uploaded_at >= ?', filters[:from]) if filters[:from]
    query = query.where('uploaded_at <= ?', filters[:to]) if filters[:to]
    query = query.where('filename ILIKE ?', "%#{filters[:filename]}%") if filters[:filename]
    query
  end
end
```

### 2.2 Update S3Service for Streaming

```ruby
# Add to app/services/s3_service.rb
class S3Service
  # ... existing code ...

  # Stream download to avoid memory issues
  def self.download_stream(s3_key, &block)
    client.get_object(bucket: bucket, key: s3_key) do |chunk|
      block.call(chunk)
    end
  rescue Aws::S3::Errors::NoSuchKey
    Rails.logger.error "S3 file not found: #{s3_key}"
    nil
  end

  # Get file info without downloading
  def self.head(s3_key)
    response = client.head_object(bucket: bucket, key: s3_key)
    {
      content_type: response.content_type,
      content_length: response.content_length,
      last_modified: response.last_modified,
      etag: response.etag,
      metadata: response.metadata
    }
  rescue Aws::S3::Errors::NotFound
    nil
  end
end
```

---

## Phase 3: Direct Replacement

### 3.1 Complete System Replacement

Since we're taking a breaking changes approach in development, we'll completely replace all old storage systems:

```ruby
# lib/tasks/clean_slate.rake
namespace :s3 do
  desc "Remove all old storage systems and implement new"
  task clean_slate: :environment do
    puts "Removing old storage systems..."

    # Drop ActiveStorage tables
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_blobs CASCADE")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_attachments CASCADE")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_variant_records CASCADE")

    # Drop old metadata table
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS office_attachment_metadata CASCADE")

    puts "Clean slate complete! Ready for new S3Manager implementation."
  end

  desc "Remove old S3 key columns"
  task remove_old_columns: :environment do
    remove_column :offices, :logo_s3_key if column_exists?(:offices, :logo_s3_key)
    remove_column :user_profiles, :avatar_s3_key if column_exists?(:user_profiles, :avatar_s3_key)
    remove_column :documents, :original_s3_key if column_exists?(:documents, :original_s3_key)
    remove_column :documents, :signed_s3_key if column_exists?(:documents, :signed_s3_key)
    remove_column :customer_files, :file_s3_key if column_exists?(:customer_files, :file_s3_key)
    remove_column :jobs, :attachment_s3_key if column_exists?(:jobs, :attachment_s3_key)

    puts "Old columns removed!"
  end
end
```

### 3.2 Update Models

```ruby
# app/models/office.rb
class Office < ApplicationRecord
  # Remove S3Attachable concern
  # include S3Attachable # REMOVED

  has_many :file_metadata, as: :attachable, dependent: :destroy

  def logo
    file_metadata.by_category('logo').first
  end

  def upload_logo(file, user_profile: nil, **options)
    # Delete old logo if exists
    logo&.destroy

    # Upload new
    S3Manager.upload(
      file,
      model: self,
      user_profile: user_profile,
      metadata: options.merge(file_type: 'logo')
    )
  end

  def logo_url(expires_in: 3600)
    logo&.url(expires_in: expires_in)
  end

  def social_contracts
    file_metadata.by_category('social_contract')
  end

  def upload_social_contract(file, user_profile: nil, system_generated: false, **options)
    S3Manager.upload(
      file,
      model: self,
      user_profile: user_profile,
      system_generated: system_generated,
      metadata: options.merge(file_type: 'social_contract')
    )
  end
end

# Similar updates for UserProfile, Document, CustomerFile...
```

---

## Phase 4: Enhanced Features

### 4.1 Temporary Uploads

```ruby
# app/models/temp_upload.rb
class TempUpload < ApplicationRecord
  belongs_to :user_profile
  belongs_to :team
  has_one :file_metadata, as: :attachable, dependent: :destroy

  validates :original_filename, presence: true

  scope :expired, -> { joins(:file_metadata).where('file_metadata.expires_at < ?', Time.current) }

  # Helper method to get User
  def user
    user_profile&.user
  end

  def self.create_from_file(file, user_profile:, team:, expires_in: 7.days)
    temp = create!(
      user_profile: user_profile,
      team: team,
      original_filename: file.original_filename
    )

    metadata = S3Manager.upload(
      file,
      model: temp,
      user_profile: user_profile,
      metadata: {
        expires_at: expires_in.from_now,
        file_category: 'temp_upload'
      }
    )

    temp
  end

  def attach_to(model, **options)
    raise "File expired" if file_metadata.expired?

    # Move file to permanent location
    S3Manager.move(file_metadata, model, options)

    # Delete temp record
    destroy
  end
end
```

### 4.2 Job Model Implementation

```ruby
# app/models/job.rb
class Job < ApplicationRecord
  belongs_to :office
  belongs_to :team
  has_many :file_metadata, as: :attachable, dependent: :destroy

  def attachments
    file_metadata.by_category('job_attachment')
  end

  def upload_attachment(file, user_profile: nil, **options)
    S3Manager.upload(
      file,
      model: self,
      user_profile: user_profile,
      metadata: options.merge(file_type: 'attachment')
    )
  end

  def attachment_urls(expires_in: 3600)
    attachments.map { |fm| fm.url(expires_in: expires_in) }
  end
end
```

### 4.3 Work Model Implementation

```ruby
# app/models/work.rb
class Work < ApplicationRecord
  belongs_to :job
  has_many :file_metadata, as: :attachable, dependent: :destroy

  DOCUMENT_TYPES = %w[procuration waiver deficiency_statement honorary].freeze

  def documents
    file_metadata.by_category('work_document')
  end

  def upload_document(file, document_type:, user_profile: nil, **options)
    raise ArgumentError, "Invalid document type" unless DOCUMENT_TYPES.include?(document_type)

    S3Manager.upload(
      file,
      model: self,
      user_profile: user_profile,
      metadata: options.merge(file_type: document_type)
    )
  end

  def documents_by_type(type)
    file_metadata.where("metadata->>'file_type' = ?", type)
  end

  def document_urls(expires_in: 3600)
    documents.map { |fm| fm.url(expires_in: expires_in) }
  end
end
```

### 4.4 Background Jobs

```ruby
# app/jobs/cleanup_expired_files_job.rb
class CleanupExpiredFilesJob < ApplicationJob
  queue_as :maintenance

  def perform
    FileMetadata.expired.find_each do |metadata|
      S3Manager.delete(metadata)
      Rails.logger.info "Deleted expired file: #{metadata.s3_key}"
    end

    TempUpload.expired.destroy_all
  end
end

# app/jobs/calculate_checksums_job.rb
class CalculateChecksumsJob < ApplicationJob
  queue_as :low

  def perform(file_metadata_id)
    metadata = FileMetadata.find(file_metadata_id)
    return if metadata.checksum.present?

    # Download and calculate checksum
    checksum = Digest::SHA256.new
    S3Manager.stream(metadata) do |chunk|
      checksum.update(chunk)
    end

    metadata.update!(checksum: checksum.hexdigest)
  end
end
```

---

## Migration Path (Breaking Changes)

### Step 1: Clean Slate (Day 1)
1. Run `rails s3:clean_slate` to remove all old storage systems
2. Create FileMetadata migration and model
3. Create TempUpload migration and model
4. Deploy S3Manager service

### Step 2: Implement New System (Day 2)
1. Update all models to use FileMetadata associations
2. Implement upload/download methods using S3Manager
3. Update all controllers to use new patterns
4. Remove all S3Attachable concerns

### Step 3: Remove Old Code (Day 3)
1. Delete S3Attachable concern file
2. Delete old S3Service patterns
3. Run `rails s3:remove_old_columns` to drop old columns
4. Remove all ActiveStorage references

### Step 4: Testing & Documentation (Day 4)
1. Test all file upload/download features
2. Verify all models work with new system
3. Update API documentation
4. Update developer guides

---

## API Specifications

### File Upload
```
POST /api/v1/files/upload
Content-Type: multipart/form-data

Parameters:
- file: File (required)
- attachable_type: String (optional, e.g., "Office")
- attachable_id: Integer (optional)
- system_generated: Boolean (default: false)
- expires_in: Integer (seconds, optional)

Response:
{
  "id": 123,
  "filename": "document.pdf",
  "content_type": "application/pdf",
  "byte_size": 1048576,
  "url": "https://s3.amazonaws.com/...",
  "checksum": "abc123...",
  "created_by_system": false,
  "file_category": "document",
  "uploaded_at": "2024-01-15T10:30:00Z"
}
```

### File Listing
```
GET /api/v1/files
Parameters:
- page: Integer
- per_page: Integer (max: 100)
- category: String
- system_only: Boolean
- user_only: Boolean
- from: Date
- to: Date
- filename: String (partial match)

Response:
{
  "files": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 123
  }
}
```

### File Movement
```
POST /api/v1/files/:id/move
Parameters:
- to_type: String (required, e.g., "Work")
- to_id: Integer (required)

Response:
{
  "success": true,
  "file": {...}
}
```

### Temporary Upload
```
POST /api/v1/files/temp
Parameters:
- file: File (required)
- expires_in: Integer (seconds, default: 604800)

Response:
{
  "id": 456,
  "temp_id": "tmp_abc123",
  "expires_at": "2024-01-22T10:30:00Z",
  "attach_url": "/api/v1/files/temp/tmp_abc123/attach"
}
```

### Attach Temporary
```
POST /api/v1/files/temp/:temp_id/attach
Parameters:
- to_type: String (required)
- to_id: Integer (required)

Response:
{
  "success": true,
  "file": {...}
}
```

---

## Testing Strategy

### Unit Tests
```ruby
# spec/models/file_metadata_spec.rb
RSpec.describe FileMetadata do
  it "validates required fields"
  it "enforces unique s3_key"
  it "scopes work correctly"
  it "generates URLs properly"
end

# spec/services/s3_manager_spec.rb
RSpec.describe S3Manager do
  it "uploads files with deduplication"
  it "moves files between models"
  it "handles upload failures gracefully"
  it "streams large files without memory issues"
end
```

### Integration Tests
```ruby
# spec/integration/file_upload_flow_spec.rb
RSpec.describe "File Upload Flow" do
  it "uploads via API and creates metadata"
  it "handles system-generated files"
  it "moves files from temp to permanent"
  it "cleans up expired files"
end
```

### Migration Tests
```ruby
# spec/lib/tasks/migration_spec.rb
RSpec.describe "Migration Tasks" do
  it "migrates ActiveStorage to S3Manager"
  it "preserves all metadata during migration"
  it "handles migration failures gracefully"
end
```

---

## Monitoring & Metrics

### Key Metrics to Track
1. **Upload Success Rate** - S3Manager uploads vs failures
2. **Deduplication Rate** - Duplicate files prevented
3. **Storage Growth** - MB/day per team
4. **Expired File Cleanup** - Files deleted vs created
5. **API Response Times** - File listing performance
6. **Migration Progress** - Files migrated vs remaining

### Dashboards
- Team storage usage
- System vs user file ratio
- File category distribution
- Upload patterns by hour/day
- Error rates and types

---

## Security Considerations

1. **Team Isolation** - Enforced via path prefixes and database queries
2. **Presigned URLs** - Time-limited, no public bucket access
3. **Audit Trail** - Track who uploaded what and when
4. **Cleanup** - Automatic removal of expired temporary files
5. **Validation** - File type, size, and content validation
6. **Checksums** - Integrity verification and deduplication

---

## Success Criteria

1. ✅ All files tracked in unified FileMetadata
2. ✅ System vs user files clearly identified
3. ✅ Fast database-driven file listing
4. ✅ Files can move between models
5. ✅ ActiveStorage completely removed
6. ✅ Single S3Manager interface
7. ✅ No data loss during migration
8. ✅ Performance improvement in file operations
9. ✅ Reduced code complexity
10. ✅ Comprehensive test coverage

---

## Timeline (Breaking Changes Implementation)

| Day | Phase | Tasks |
|-----|-------|-------|
| 1 | Clean Slate | Remove old systems, create FileMetadata |
| 2 | Implementation | Deploy S3Manager, update all models |
| 3 | Replacement | Remove old code, columns, and concerns |
| 4 | Testing | Complete testing and documentation |
| 5 | Finalization | Performance tuning and monitoring setup |

---

## Conclusion

This breaking changes strategy provides:
- **Unified** file tracking across all models including Jobs and Works
- **UserProfile-centric** attachments for consistent user tracking
- **Performance** through database queries instead of S3 operations
- **Simplicity** through single S3Manager interface and cleaner list_by_team
- **Clean Architecture** complete removal of legacy code
- **Fast Implementation** 5-day complete replacement in development
- **No Technical Debt** fresh start without backward compatibility baggage

The breaking changes approach allows for a clean, fast implementation perfect for development environments.
