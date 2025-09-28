# frozen_string_literal: true

module S3Attachable
  extend ActiveSupport::Concern
  include S3PathBuilder

  def upload_logo(file, metadata = {})
    LogoUploader.new(self, file, metadata).upload
  end

  def upload_social_contract(file, metadata = {})
    SocialContractUploader.new(self, file, metadata).upload
  end

  def upload_avatar(file, metadata = {})
    AvatarUploader.new(self, file, metadata).upload
  end

  def logo_url(expires_in: 3600, **)
    return nil unless respond_to?(:logo_s3_key) && logo_s3_key.present?

    generate_presigned_url(logo_s3_key, expires_in: expires_in)
  end

  def avatar_url(expires_in: 3600, **)
    return nil unless respond_to?(:avatar_s3_key) && avatar_s3_key.present?

    generate_presigned_url(avatar_s3_key, expires_in: expires_in)
  end

  def social_contracts_with_urls(expires_in: 3600)
    return [] unless respond_to?(:attachment_metadata)

    attachment_metadata.where(document_type: 'social_contract').map do |metadata|
      SocialContractPresenter.new(metadata, expires_in).simple_attributes
    end
  end

  def social_contracts_with_metadata(expires_in: 3600)
    return [] unless respond_to?(:attachment_metadata)

    attachment_metadata.where(document_type: 'social_contract').map do |metadata|
      SocialContractPresenter.new(metadata, expires_in).full_attributes
    end
  end

  def delete_logo!
    LogoDeleter.new(self).delete
  end

  def delete_avatar!
    AvatarDeleter.new(self).delete
  end

  def delete_social_contract!(attachment_id)
    SocialContractDeleter.new(self, attachment_id).delete
  end

  private

  def build_metadata(custom_metadata = {})
    MetadataBuilder.new(self, custom_metadata).build
  end

  class BaseUploader
    def initialize(model, file, metadata = {})
      @model = model
      @file = file
      @metadata = metadata
    end

    def upload
      return false if @file.blank?

      extension = file_extension
      new_s3_key = build_s3_key(extension)

      delete_existing_file if should_delete_existing?

      perform_upload(new_s3_key)
    end

    private

    def file_extension
      File.extname(@file.original_filename).delete('.').downcase
    end

    def should_delete_existing?
      false
    end

    def perform_upload(s3_key)
      if S3Service.upload(@file, s3_key, @model.build_metadata(@metadata))
        handle_successful_upload(s3_key)
        log_success
        true
      else
        false
      end
    rescue StandardError => e
      log_error(e)
      add_error(e)
      false
    end

    def handle_successful_upload(s3_key)
      # Override in subclasses
    end

    def log_success
      Rails.logger.info success_message
    end

    def log_error(error)
      Rails.logger.error error_message(error)
    end

    def add_error(error)
      @model.errors.add(error_field, "Upload failed: #{error.message}")
    end

    def success_message
      "#{file_type.capitalize} uploaded successfully for #{@model.class.name} ###{@model.id}"
    end

    def error_message(error)
      "#{file_type.capitalize} upload failed for #{@model.class.name} ###{@model.id}: #{error.message}"
    end
  end

  class LogoUploader < BaseUploader
    def build_s3_key(extension)
      @model.build_logo_s3_key(extension)
    end

    def should_delete_existing?
      @model.logo_s3_key.present?
    end

    def delete_existing_file
      S3Service.delete(@model.logo_s3_key)
    rescue StandardError
      nil
    end

    def handle_successful_upload(s3_key)
      @model.update!(logo_s3_key: s3_key)
    end

    def file_type
      'logo'
    end

    def error_field
      :logo
    end
  end

  class AvatarUploader < BaseUploader
    def build_s3_key(extension)
      @model.build_avatar_s3_key(extension)
    end

    def should_delete_existing?
      @model.avatar_s3_key.present?
    end

    def delete_existing_file
      S3Service.delete(@model.avatar_s3_key)
    rescue StandardError
      nil
    end

    def handle_successful_upload(s3_key)
      @model.update!(avatar_s3_key: s3_key)
    end

    def file_type
      'avatar'
    end

    def error_field
      :avatar
    end
  end

  class SocialContractUploader < BaseUploader
    def build_s3_key(extension)
      @model.build_social_contract_s3_key(extension)
    end

    def handle_successful_upload(s3_key)
      @model.attachment_metadata.create!(
        document_type: 'social_contract',
        s3_key: s3_key,
        filename: @file.original_filename,
        content_type: @file.content_type,
        byte_size: @file.size,
        uploaded_by_id: @metadata[:uploaded_by_id]
      )
    end

    def file_type
      'social contract'
    end

    def error_field
      :social_contract
    end
  end

  class SocialContractPresenter
    def initialize(metadata, expires_in)
      @metadata = metadata
      @expires_in = expires_in
    end

    def simple_attributes
      {
        id: @metadata.id,
        filename: @metadata.filename,
        content_type: @metadata.content_type,
        byte_size: @metadata.byte_size,
        uploaded_at: @metadata.created_at,
        uploaded_by_id: @metadata.uploaded_by_id,
        url: url,
        download_url: download_url
      }
    end

    def full_attributes
      simple_attributes.merge(
        s3_key: @metadata.s3_key,
        created_at: @metadata.created_at,
        document_date: @metadata.document_date,
        description: @metadata.description,
        custom_metadata: @metadata.custom_metadata
      )
    end

    private

    def url
      S3PathBuilder.generate_presigned_url(@metadata.s3_key, expires_in: @expires_in)
    end

    def download_url
      S3PathBuilder.generate_presigned_download_url(
        @metadata.s3_key,
        @metadata.filename,
        expires_in: @expires_in
      )
    end
  end

  class LogoDeleter
    def initialize(model)
      @model = model
    end

    def delete
      return true unless should_delete?

      if S3Service.delete(@model.logo_s3_key)
        @model.update!(logo_s3_key: nil)
        true
      else
        false
      end
    rescue StandardError => e
      log_error(e)
      false
    end

    private

    def should_delete?
      @model.respond_to?(:logo_s3_key) && @model.logo_s3_key.present?
    end

    def log_error(error)
      Rails.logger.error "Failed to delete logo for #{@model.class.name} ###{@model.id}: #{error.message}"
    end
  end

  class AvatarDeleter
    def initialize(model)
      @model = model
    end

    def delete
      return true unless should_delete?

      if S3Service.delete(@model.avatar_s3_key)
        @model.update!(avatar_s3_key: nil)
        true
      else
        false
      end
    rescue StandardError => e
      log_error(e)
      false
    end

    private

    def should_delete?
      @model.respond_to?(:avatar_s3_key) && @model.avatar_s3_key.present?
    end

    def log_error(error)
      Rails.logger.error "Failed to delete avatar for #{@model.class.name} ###{@model.id}: #{error.message}"
    end
  end

  class SocialContractDeleter
    def initialize(model, attachment_id)
      @model = model
      @attachment_id = attachment_id
    end

    def delete
      attachment = find_attachment
      return false unless attachment

      if S3Service.delete(attachment.s3_key)
        attachment.destroy
        true
      else
        false
      end
    rescue StandardError => e
      log_error(e)
      false
    end

    private

    def find_attachment
      @model.attachment_metadata.find_by(id: @attachment_id, document_type: 'social_contract')
    end

    def log_error(error)
      Rails.logger.error "Failed to delete social contract ###{@attachment_id}: #{error.message}"
    end
  end

  class MetadataBuilder
    def initialize(model, custom_metadata)
      @model = model
      @custom_metadata = custom_metadata
    end

    def build
      base_metadata.merge(processed_custom_metadata)
    end

    private

    def base_metadata
      {
        model_type: @model.class.name,
        model_id: @model.id.to_s,
        team_id: @model.team_id.to_s
      }
    end

    def processed_custom_metadata
      metadata = @custom_metadata.dup
      metadata[:uploaded_by_id] = metadata.delete(:uploaded_by_id).to_s if metadata[:uploaded_by_id]
      metadata.transform_values(&:to_s)
    end
  end
end
