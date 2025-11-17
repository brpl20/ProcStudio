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
  belongs_to :uploaded_by, class_name: 'User', optional: true

  # Core tracking fields
  # - s3_key: string (unique, indexed)
  # - filename: string
  # - content_type: string
  # - byte_size: bigint
  # - checksum: string (SHA256, for deduplication)
  # - created_by_system: boolean (tracks system vs user files)
  # - file_category: string (logo, avatar, social_contract, etc.)
  # - metadata: jsonb (flexible key-value storage)
  # - uploaded_at: datetime
  # - expires_at: datetime (for temporary files)

  # Scopes for filtering
  scope :system_generated, -> { where(created_by_system: true) }
  scope :user_uploaded, -> { where(created_by_system: false) }
  scope :by_category, ->(cat) { where(file_category: cat) }
  scope :temporary, -> { where.not(expires_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
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
      uploaded_by: metadata[:current_user],
      file_category: detect_category(model, s3_key),
      metadata: metadata.except(:current_user, :force_upload),
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
    when User, UserProfile
      user_path(model, options)
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

  def user_path(user, options = {})
    user_id = user.is_a?(UserProfile) ? user.user_id : user.id
    team_id = extract_team_id(user)
    ext = options[:extension] || 'jpg'

    "#{base_prefix(team_id)}/users/#{user_id}/avatar/avatar-#{timestamp}.#{ext}"
  end

  def temp_path(temp_upload, options = {})
    "#{base_prefix(temp_upload.team_id)}/temp-uploads/#{temp_upload.user_id}/#{timestamp}-#{temp_upload.original_filename}"
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
              when User then model.current_team&.id || model.team&.id
              when UserProfile then model.user&.team&.id || model.office&.team_id
              end

    raise TeamNotFoundError, "Cannot determine team for #{model.class}" if team_id.nil?
    team_id
  end
end
```

#### 4. TempUpload Model (For Undesignated Files)
```ruby
class TempUpload < ApplicationRecord
  belongs_to :user
  belongs_to :team

  # Fields:
  # - s3_key: string
  # - original_filename: string
  # - content_type: string
  # - byte_size: bigint
  # - expires_at: datetime (default: 7.days.from_now)
  # - metadata: jsonb

  scope :expired, -> { where('expires_at < ?', Time.current) }

  # Attach temporary file to a model
  def attach_to(model, as: :attachment)
    file_metadata = FileMetadata.find_by(s3_key: s3_key)

    S3Manager.move(file_metadata, model)

    # Clean up temp record
    destroy
  end

  # Create from upload
  def self.create_from_upload(file, user:, team:)
    s3_key = PathGenerator.for_temp(user, team, file.original_filename)

    S3Service.upload(file, s3_key)

    create!(
      user: user,
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

1. **Non-Breaking Changes** - Maintain backward compatibility during migration
2. **Incremental Migration** - Phase by phase, model by model
3. **Data Integrity** - Never lose files or metadata
4. **Performance First** - Database queries over S3 operations
5. **Clean Architecture** - Single responsibility, clear interfaces

### Development Approach

1. **Parallel Implementation** - New system runs alongside old
2. **Feature Flags** - Toggle between old and new per model
3. **Comprehensive Testing** - Unit, integration, and migration tests
4. **Monitoring** - Track both systems during transition
5. **Rollback Plan** - Can revert at any phase

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
      t.references :uploaded_by, foreign_key: { to_table: :users }
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
  belongs_to :uploaded_by, class_name: 'User', optional: true

  validates :s3_key, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :byte_size, presence: true, numericality: { greater_than: 0 }
  validates :checksum, presence: true
  validates :file_category, inclusion: { in: FILE_CATEGORIES }, allow_nil: true

  FILE_CATEGORIES = %w[
    logo avatar social_contract
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
end
```

### 1.4 Migrate Existing Data

```ruby
# lib/tasks/migrate_to_file_metadata.rake
namespace :s3 do
  desc "Migrate existing S3 files to FileMetadata"
  task migrate_metadata: :environment do
    puts "Starting metadata migration..."

    # Migrate Office logos
    Office.where.not(logo_s3_key: nil).find_each do |office|
      FileMetadata.find_or_create_by(s3_key: office.logo_s3_key) do |fm|
        fm.attachable = office
        fm.filename = File.basename(office.logo_s3_key)
        fm.content_type = 'image/jpeg' # Default, could detect from extension
        fm.byte_size = S3Service.get_object_metadata(office.logo_s3_key)[:content_length] rescue 0
        fm.checksum = Digest::SHA256.hexdigest(office.logo_s3_key) # Placeholder
        fm.created_by_system = false
        fm.file_category = 'logo'
        fm.uploaded_at = office.updated_at
      end
      print '.'
    end

    # Migrate Office social contracts
    OfficeAttachmentMetadata.social_contracts.find_each do |attachment|
      FileMetadata.find_or_create_by(s3_key: attachment.s3_key) do |fm|
        fm.attachable = attachment.office
        fm.filename = attachment.filename
        fm.content_type = attachment.content_type
        fm.byte_size = attachment.byte_size
        fm.checksum = Digest::SHA256.hexdigest(attachment.s3_key) # Placeholder
        fm.created_by_system = attachment.custom_metadata&.dig('system_generated') || false
        fm.file_category = 'social_contract'
        fm.uploaded_by_id = attachment.uploaded_by_id
        fm.metadata = attachment.custom_metadata || {}
        fm.uploaded_at = attachment.created_at
      end
      print '.'
    end

    # Migrate UserProfile avatars
    UserProfile.where.not(avatar_s3_key: nil).find_each do |profile|
      FileMetadata.find_or_create_by(s3_key: profile.avatar_s3_key) do |fm|
        fm.attachable = profile
        fm.filename = File.basename(profile.avatar_s3_key)
        fm.content_type = 'image/jpeg' # Default
        fm.byte_size = S3Service.get_object_metadata(profile.avatar_s3_key)[:content_length] rescue 0
        fm.checksum = Digest::SHA256.hexdigest(profile.avatar_s3_key)
        fm.created_by_system = false
        fm.file_category = 'avatar'
        fm.uploaded_at = profile.updated_at
      end
      print '.'
    end

    puts "\nMigration complete!"
    puts "Total FileMetadata records: #{FileMetadata.count}"
  end
end
```

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

  def upload(file, model: nil, path: nil, system_generated: false, user: nil, metadata: {})
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
      S3Service.upload(file, s3_key, build_s3_metadata(model, user, metadata))
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
      uploaded_by: user,
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
    when UserProfile, User
      'avatar'
    when Work
      detect_work_document_type(s3_key)
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

  def build_s3_metadata(model, user, custom_metadata)
    metadata = {
      'uploaded-by' => user&.id&.to_s,
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
    # Complex join to get files for a team
    FileMetadata
      .joins("LEFT JOIN offices ON attachable_type = 'Office' AND attachable_id = offices.id")
      .joins("LEFT JOIN users ON attachable_type = 'User' AND attachable_id = users.id")
      .joins("LEFT JOIN user_profiles ON attachable_type = 'UserProfile' AND attachable_id = user_profiles.id")
      .joins("LEFT JOIN user_profiles up2 ON up2.user_id = users.id")
      .where(
        "offices.team_id = :team_id OR users.team_id = :team_id OR up2.office_id IN (SELECT id FROM offices WHERE team_id = :team_id)",
        team_id: team_id
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

## Phase 3: ActiveStorage Removal

### 3.1 Migration Script

```ruby
# lib/tasks/migrate_from_active_storage.rake
namespace :active_storage do
  desc "Migrate ActiveStorage files to S3Manager"
  task migrate_to_s3: :environment do
    require 'open-uri'

    puts "Starting ActiveStorage migration..."

    # Migrate UserProfile avatars
    UserProfile.joins(:avatar_attachment).find_each do |profile|
      next if profile.avatar_s3_key.present? # Skip if already migrated

      blob = profile.avatar.blob

      # Download from ActiveStorage
      tempfile = Tempfile.new(['avatar', blob.filename.extension_with_delimiter])
      tempfile.binmode
      blob.download { |chunk| tempfile.write(chunk) }
      tempfile.rewind

      # Upload via S3Manager
      file_wrapper = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: blob.filename.to_s,
        content_type: blob.content_type
      )

      metadata = S3Manager.upload(
        file_wrapper,
        model: profile,
        user: profile.user,
        metadata: { migrated_from: 'active_storage', blob_id: blob.id }
      )

      # Update model
      profile.update_column(:avatar_s3_key, metadata.s3_key)

      tempfile.close!
      print '.'
    rescue => e
      puts "\nFailed to migrate avatar for UserProfile #{profile.id}: #{e.message}"
    end

    # Similar for Document and CustomerFile...

    puts "\nMigration complete!"
  end

  desc "Remove ActiveStorage tables"
  task remove_tables: :environment do
    if FileMetadata.count > 0 && ActiveStorage::Blob.count == 0
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_blobs CASCADE")
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_attachments CASCADE")
      ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_storage_variant_records CASCADE")
      puts "ActiveStorage tables removed successfully"
    else
      puts "Cannot remove tables - migration not complete or no FileMetadata records"
    end
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

  def upload_logo(file, user: nil, **options)
    # Delete old logo if exists
    logo&.destroy

    # Upload new
    S3Manager.upload(
      file,
      model: self,
      user: user,
      metadata: options.merge(file_type: 'logo')
    )
  end

  def logo_url(expires_in: 3600)
    logo&.url(expires_in: expires_in)
  end

  def social_contracts
    file_metadata.by_category('social_contract')
  end

  def upload_social_contract(file, user: nil, system_generated: false, **options)
    S3Manager.upload(
      file,
      model: self,
      user: user,
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
  belongs_to :user
  belongs_to :team
  has_one :file_metadata, as: :attachable, dependent: :destroy

  validates :original_filename, presence: true

  scope :expired, -> { joins(:file_metadata).where('file_metadata.expires_at < ?', Time.current) }

  def self.create_from_file(file, user:, team:, expires_in: 7.days)
    temp = create!(
      user: user,
      team: team,
      original_filename: file.original_filename
    )

    metadata = S3Manager.upload(
      file,
      model: temp,
      user: user,
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

### 4.2 Background Jobs

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

## Migration Path

### Step 1: Deploy FileMetadata (Week 1)
1. Create migration and model
2. Deploy to production
3. Start dual-writing (old system + FileMetadata)
4. Run migration rake task for existing files

### Step 2: Switch Reads (Week 2)
1. Update models to read from FileMetadata
2. Add feature flag for rollback
3. Monitor for issues
4. Keep writing to both systems

### Step 3: Stop Dual Writing (Week 3)
1. Remove old upload code
2. Remove S3Attachable concern
3. Update controllers to use S3Manager
4. Keep old data for rollback

### Step 4: Cleanup (Week 4)
1. Remove ActiveStorage
2. Drop old columns (logo_s3_key, avatar_s3_key)
3. Drop OfficeAttachmentMetadata table
4. Remove old code

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

## Rollback Plan

Each phase can be rolled back independently:

### Phase 1 Rollback
- Keep FileMetadata table but stop using it
- Continue with existing system

### Phase 2 Rollback
- Switch back to S3Attachable/S3Service
- Keep S3Manager for future retry

### Phase 3 Rollback
- Restore ActiveStorage associations
- Re-enable dual writing

### Phase 4 Rollback
- Disable enhanced features
- Return to basic implementation

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

## Timeline

| Week | Phase | Tasks |
|------|-------|-------|
| 1-2 | Phase 1 | Create FileMetadata, migrate existing data |
| 3 | Phase 2 | Implement S3Manager, update models |
| 4 | Phase 3 | Remove ActiveStorage, cleanup |
| 5 | Phase 4 | Enhanced features, monitoring |
| 6 | Testing | End-to-end testing, performance validation |
| 7 | Deploy | Production rollout with monitoring |
| 8 | Cleanup | Remove old code, documentation |

---

## Conclusion

This strategy provides:
- **Unified** file tracking across all models
- **Performance** through database queries instead of S3 operations
- **Flexibility** to mark files as system-generated
- **Simplicity** through single S3Manager interface
- **Reliability** through checksums and deduplication
- **Scalability** through efficient queries and streaming

The phased approach ensures zero downtime and safe rollback at any point.