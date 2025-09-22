# frozen_string_literal: true

module S3Attachable
  extend ActiveSupport::Concern
  include S3PathBuilder

  # Upload logo for Office model
  def upload_logo(file, metadata = {})
    return false if file.blank?

    extension = File.extname(file.original_filename).delete('.').downcase
    new_s3_key = build_logo_s3_key(extension)

    # Delete old logo if exists
    if logo_s3_key.present?
      S3Service.delete(logo_s3_key) rescue nil
    end

    # Upload new logo
    if S3Service.upload(file, new_s3_key, build_metadata(metadata))
      update_column(:logo_s3_key, new_s3_key)
      Rails.logger.info "Logo uploaded successfully for #{self.class.name} ##{id}"
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Logo upload failed for #{self.class.name} ##{id}: #{e.message}"
    errors.add(:logo, "Upload failed: #{e.message}")
    false
  end

  # Upload social contract for Office model
  def upload_social_contract(file, metadata = {})
    return false if file.blank?

    extension = File.extname(file.original_filename).delete('.').downcase
    s3_key = build_social_contract_s3_key(extension)

    if S3Service.upload(file, s3_key, build_metadata(metadata))
      # Store reference in attachment_metadata table
      attachment_metadata.create!(
        document_type: 'social_contract',
        s3_key: s3_key,
        filename: file.original_filename,
        content_type: file.content_type,
        byte_size: file.size,
        uploaded_by_id: metadata[:uploaded_by_id]
      )
      Rails.logger.info "Social contract uploaded successfully for Office ##{id}"
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Social contract upload failed for Office ##{id}: #{e.message}"
    errors.add(:social_contract, "Upload failed: #{e.message}")
    false
  end

  # Upload avatar for User/UserProfile model
  def upload_avatar(file, metadata = {})
    return false if file.blank?

    extension = File.extname(file.original_filename).delete('.').downcase
    new_s3_key = build_avatar_s3_key(extension)

    # Delete old avatar if exists
    if avatar_s3_key.present?
      S3Service.delete(avatar_s3_key) rescue nil
    end

    # Upload new avatar
    if S3Service.upload(file, new_s3_key, build_metadata(metadata))
      update_column(:avatar_s3_key, new_s3_key)
      Rails.logger.info "Avatar uploaded successfully for #{self.class.name} ##{id}"
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Avatar upload failed for #{self.class.name} ##{id}: #{e.message}"
    errors.add(:avatar, "Upload failed: #{e.message}")
    false
  end

  # Get presigned URL for logo
  def logo_url(expires_in: 3600, only_path: nil)
    # only_path parameter is for backwards compatibility with ActiveStorage
    return nil unless respond_to?(:logo_s3_key) && logo_s3_key.present?
    generate_presigned_url(logo_s3_key, expires_in: expires_in)
  end

  # Get presigned URL for avatar
  def avatar_url(expires_in: 3600, only_path: nil)
    # only_path parameter is for backwards compatibility with ActiveStorage
    return nil unless respond_to?(:avatar_s3_key) && avatar_s3_key.present?
    generate_presigned_url(avatar_s3_key, expires_in: expires_in)
  end

  # Get social contracts with presigned URLs
  def social_contracts_with_urls(expires_in: 3600)
    return [] unless respond_to?(:attachment_metadata)
    
    attachment_metadata.where(document_type: 'social_contract').map do |metadata|
      {
        id: metadata.id,
        filename: metadata.filename,
        content_type: metadata.content_type,
        byte_size: metadata.byte_size,
        uploaded_at: metadata.created_at,
        uploaded_by_id: metadata.uploaded_by_id,
        url: generate_presigned_url(metadata.s3_key, expires_in: expires_in),
        download_url: generate_presigned_download_url(
          metadata.s3_key,
          metadata.filename,
          expires_in: expires_in
        )
      }
    end
  end

  # Alias for backwards compatibility with serializers
  def social_contracts_with_metadata(expires_in: 3600)
    return [] unless respond_to?(:attachment_metadata)
    
    attachment_metadata.where(document_type: 'social_contract').map do |metadata|
      {
        id: metadata.id,
        s3_key: metadata.s3_key,
        filename: metadata.filename,
        content_type: metadata.content_type,
        byte_size: metadata.byte_size,
        created_at: metadata.created_at,
        url: generate_presigned_url(metadata.s3_key, expires_in: expires_in),
        download_url: generate_presigned_download_url(
          metadata.s3_key,
          metadata.filename,
          expires_in: expires_in
        ),
        # Metadata fields
        document_date: metadata.document_date,
        description: metadata.description,
        uploaded_by_id: metadata.uploaded_by_id,
        custom_metadata: metadata.custom_metadata
      }
    end
  end

  # Delete logo from S3
  def delete_logo!
    return true unless respond_to?(:logo_s3_key) || logo_s3_key.blank?

    if S3Service.delete(logo_s3_key)
      update_column(:logo_s3_key, nil)
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Failed to delete logo for #{self.class.name} ##{id}: #{e.message}"
    false
  end

  # Delete avatar from S3
  def delete_avatar!
    return true unless respond_to?(:avatar_s3_key) || avatar_s3_key.blank?

    if S3Service.delete(avatar_s3_key)
      update_column(:avatar_s3_key, nil)
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Failed to delete avatar for #{self.class.name} ##{id}: #{e.message}"
    false
  end

  # Delete social contract from S3
  def delete_social_contract!(attachment_id)
    attachment = attachment_metadata.find_by(id: attachment_id, document_type: 'social_contract')
    return false unless attachment

    if S3Service.delete(attachment.s3_key)
      attachment.destroy
      true
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Failed to delete social contract ##{attachment_id}: #{e.message}"
    false
  end

  private

  def build_metadata(custom_metadata = {})
    base_metadata = {
      model_type: self.class.name,
      model_id: id.to_s,
      team_id: team_id.to_s
    }
    
    base_metadata[:uploaded_by_id] = custom_metadata.delete(:uploaded_by_id).to_s if custom_metadata[:uploaded_by_id]
    base_metadata.merge(custom_metadata.transform_values(&:to_s))
  end
end