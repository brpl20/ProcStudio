# Improved S3 upload handling for Office model
module OfficeS3Uploads
  extend ActiveSupport::Concern

  # Upload logo with proper transaction handling
  def upload_logo_safe(file, metadata_params = {})
    Rails.logger.info "upload_logo_safe called with file: #{file.inspect}"
    return false if file.blank?

    Rails.logger.info "File details - filename: #{file.original_filename}, content_type: #{file.content_type}, size: #{file.size}"
    
    extension = File.extname(file.original_filename).delete('.')
    s3_key = build_logo_s3_key(extension)
    Rails.logger.info "Generated S3 key: #{s3_key}"
    
    # Read file content before any database operations
    file_content = file.respond_to?(:tempfile) ? file.tempfile.read : file.read
    file_content = file_content.force_encoding('BINARY') if file_content.respond_to?(:force_encoding)
    
    # First, try to update the database (this will validate)
    # Use update_column to skip validations if needed
    success = if skip_validations_for_logo_upload?
                update_column(:logo_s3_key, s3_key)
              else
                update(logo_s3_key: s3_key)
              end
    
    if success
      Rails.logger.info "Logo S3 key updated successfully in database"
      
      # Only upload to S3 after successful database update
      if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_BUCKET'].present?
        begin
          s3_client.put_object(
            bucket: ENV['S3_BUCKET'],
            key: s3_key,
            body: file_content,
            content_type: file.content_type,
            metadata: {
              'team-id' => team_id.to_s,
              'office-id' => id.to_s,
              'uploaded-by' => metadata_params[:uploaded_by_id].to_s
            }
          )
          Rails.logger.info "Logo uploaded successfully to S3: #{s3_key}"
        rescue StandardError => e
          Rails.logger.error "Failed to upload to S3: #{e.message}"
          # Rollback the database change
          update_column(:logo_s3_key, logo_s3_key_was)
          errors.add(:logo, "Failed to upload to S3: #{e.message}")
          return false
        end
      else
        Rails.logger.warn "S3 not configured, storing file path reference only"
      end
      
      # Create metadata record if needed
      if metadata_params.present?
        begin
          attachment_metadata.create!(
            document_type: 'logo',
            s3_key: s3_key,
            filename: file.original_filename,
            content_type: file.content_type,
            byte_size: file.size,
            document_date: metadata_params[:document_date],
            description: metadata_params[:description],
            custom_metadata: metadata_params[:custom_metadata],
            uploaded_by_id: metadata_params[:uploaded_by_id]
          )
        rescue StandardError => e
          Rails.logger.error "Failed to create metadata: #{e.message}"
          # Don't fail the upload if metadata creation fails
        end
      end
      
      true
    else
      Rails.logger.error "Failed to update logo S3 key in database: #{errors.full_messages}"
      errors.add(:logo, "Failed to save logo reference: #{errors.full_messages.join(', ')}")
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error in upload_logo_safe: #{e.message}"
    errors.add(:logo, "Upload failed: #{e.message}")
    false
  end
  
  # Alternative: Upload logo in a separate transaction
  def upload_logo_isolated(file, metadata_params = {})
    Rails.logger.info "upload_logo_isolated called"
    return false if file.blank?
    
    extension = File.extname(file.original_filename).delete('.')
    s3_key = build_logo_s3_key(extension)
    
    # Read file content
    file_content = file.respond_to?(:tempfile) ? file.tempfile.read : file.read
    file_content = file_content.force_encoding('BINARY') if file_content.respond_to?(:force_encoding)
    
    # Run in isolated transaction to avoid validation conflicts
    Office.transaction do
      # Reload to get fresh state
      reload
      
      # Update only the logo field, skipping validations
      self.logo_s3_key = s3_key
      save!(validate: false)
      
      # Upload to S3
      if ENV['AWS_ACCESS_KEY_ID'].present? && ENV['S3_BUCKET'].present?
        s3_client.put_object(
          bucket: ENV['S3_BUCKET'],
          key: s3_key,
          body: file_content,
          content_type: file.content_type,
          metadata: {
            'team-id' => team_id.to_s,
            'office-id' => id.to_s,
            'uploaded-by' => metadata_params[:uploaded_by_id].to_s
          }
        )
      end
      
      true
    end
  rescue StandardError => e
    Rails.logger.error "Error in upload_logo_isolated: #{e.message}"
    errors.add(:logo, "Upload failed: #{e.message}")
    false
  end

  private

  def skip_validations_for_logo_upload?
    # Skip validations if office has incomplete partner setup
    # This allows logo upload even when partnerships aren't finalized
    user_offices.where(partnership_type: 'socio').any? && 
      user_offices.where(partnership_type: 'socio').sum(:partnership_percentage) != 100.0
  end
end