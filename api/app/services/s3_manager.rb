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

    # Add filename to metadata for PathGenerator to extract extension
    filename = extract_filename(file)
    metadata_with_filename = metadata.merge(filename: filename)

    # Generate path
    s3_key = path || PathGenerator.for(model, metadata_with_filename)

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
      filename: filename,
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
    # Collect all IDs for each model type
    office_ids = Office.where(team_id: team_id).pluck(:id)
    user_profile_ids = UserProfile.joins(:user)
                                   .where(users: { team_id: team_id })
                                   .or(UserProfile.where(office_id: office_ids))
                                   .pluck(:id)
    job_ids = Job.where(team_id: team_id).pluck(:id)
    work_ids = Work.where(team_id: team_id).pluck(:id)
    temp_upload_ids = TempUpload.where(team_id: team_id).pluck(:id)

    # Build conditions for each type
    conditions = []
    conditions << { attachable_type: 'Office', attachable_id: office_ids } if office_ids.any?
    conditions << { attachable_type: 'UserProfile', attachable_id: user_profile_ids } if user_profile_ids.any?
    conditions << { attachable_type: 'Job', attachable_id: job_ids } if job_ids.any?
    conditions << { attachable_type: 'Work', attachable_id: work_ids } if work_ids.any?
    conditions << { attachable_type: 'TempUpload', attachable_id: temp_upload_ids } if temp_upload_ids.any?

    # Return empty if no conditions
    return FileMetadata.none if conditions.empty?

    # Build the query using OR conditions
    query = FileMetadata.where(conditions.shift)
    conditions.each do |condition|
      query = query.or(FileMetadata.where(condition))
    end

    query
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