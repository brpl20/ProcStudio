# frozen_string_literal: true

# Service for transferring attachments between models
class AttachmentTransferService
  include ServiceBase

  attr_reader :file_metadata, :target_model, :user_profile, :options

  def initialize(file_metadata:, target_model:, user_profile:, options: {})
    @file_metadata = file_metadata
    @target_model = target_model
    @user_profile = user_profile
    @options = options
  end

  def call
    validate_transfer!

    ActiveRecord::Base.transaction do
      # Store original values for rollback if needed
      original_type = file_metadata.attachable_type
      original_id = file_metadata.attachable_id
      original_path = file_metadata.s3_key

      begin
        # Update file metadata with new attachable
        file_metadata.update!(
          attachable_type: target_model.class.name,
          attachable_id: target_model.id,
          transferred_at: Time.current,
          transferred_by_id: user_profile.id,
          transfer_metadata: build_transfer_metadata(original_type, original_id)
        )

        # Optionally move the file in S3 to maintain organized structure
        if options[:reorganize_s3] && should_reorganize_path?
          new_s3_key = generate_new_s3_key
          S3Manager.move_file(from: original_path, to: new_s3_key)
          file_metadata.update!(s3_key: new_s3_key)
        end

        # Log the transfer for audit purposes
        log_transfer(original_type, original_id)

        success_result(file_metadata: file_metadata, message: 'Attachment transferred successfully')
      rescue StandardError => e
        Rails.logger.error "Transfer failed: #{e.message}"
        error_result("Transfer failed: #{e.message}")
      end
    end
  end

  private

  def validate_transfer!
    raise ArgumentError, 'File metadata not found' unless file_metadata
    raise ArgumentError, 'Target model not found' unless target_model
    raise ArgumentError, 'User profile required' unless user_profile

    # Don't allow transfer to the same model
    if file_metadata.attachable_type == target_model.class.name &&
       file_metadata.attachable_id == target_model.id
      raise ArgumentError, 'Cannot transfer to the same model'
    end

    # Validate that target model supports attachments
    unless target_model.respond_to?(:file_metadata)
      raise ArgumentError, "#{target_model.class.name} does not support attachments"
    end

    # Additional validations for specific file types
    validate_file_type_compatibility! if options[:validate_compatibility]
  end

  def validate_file_type_compatibility!
    # Don't allow moving avatars to non-UserProfile models
    if file_metadata.file_type == 'avatar' && target_model.class.name != 'UserProfile'
      raise ArgumentError, 'Avatar files can only be attached to UserProfiles'
    end

    # Don't allow moving logos to non-Office models
    if file_metadata.file_type == 'logo' && target_model.class.name != 'Office'
      raise ArgumentError, 'Logo files can only be attached to Offices'
    end

    # Don't allow moving social contracts to non-Office models
    if file_metadata.file_type == 'social_contract' && target_model.class.name != 'Office'
      raise ArgumentError, 'Social contract files can only be attached to Offices'
    end
  end

  def should_reorganize_path?
    # Only reorganize if the path contains model-specific information
    file_metadata.s3_key.include?(file_metadata.attachable_type.underscore)
  end

  def generate_new_s3_key
    # Generate new path based on target model
    PathGenerator.for(target_model, {
      file_type: file_metadata.file_type,
      filename: file_metadata.filename,
      extension: File.extname(file_metadata.filename).delete_prefix('.')
    })
  end

  def build_transfer_metadata(original_type, original_id)
    {
      from_type: original_type,
      from_id: original_id,
      transferred_at: Time.current.iso8601,
      transferred_by: user_profile.id,
      reason: options[:reason]
    }.compact
  end

  def log_transfer(original_type, original_id)
    Rails.logger.info(
      "Attachment transferred: FileMetadata##{file_metadata.id} " \
      "from #{original_type}##{original_id} to #{target_model.class.name}##{target_model.id} " \
      "by UserProfile##{user_profile.id}"
    )

    # Create audit log entry if audit model exists
    if defined?(AuditLog)
      AuditLog.create!(
        action: 'attachment_transfer',
        auditable: file_metadata,
        user_profile: user_profile,
        changes: {
          from: "#{original_type}##{original_id}",
          to: "#{target_model.class.name}##{target_model.id}"
        }
      )
    end
  end
end