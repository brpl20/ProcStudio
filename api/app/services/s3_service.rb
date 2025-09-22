# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Service
  class << self
    def upload(file, s3_key, metadata = {})
      return false if file.blank? || s3_key.blank?

      # Read file content
      file_content = extract_file_content(file)
      
      # Upload to S3
      client.put_object(
        bucket: bucket_name,
        key: s3_key,
        body: file_content,
        content_type: extract_content_type(file),
        metadata: stringify_metadata(metadata)
      )

      Rails.logger.info "Successfully uploaded file to S3: #{s3_key}"
      true
    rescue StandardError => e
      Rails.logger.error "S3 upload failed for #{s3_key}: #{e.message}"
      raise
    end

    def delete(s3_key)
      return false if s3_key.blank?

      client.delete_object(
        bucket: bucket_name,
        key: s3_key
      )

      Rails.logger.info "Successfully deleted file from S3: #{s3_key}"
      true
    rescue StandardError => e
      Rails.logger.error "S3 delete failed for #{s3_key}: #{e.message}"
      raise
    end

    def exists?(s3_key)
      return false if s3_key.blank?

      client.head_object(
        bucket: bucket_name,
        key: s3_key
      )
      true
    rescue Aws::S3::Errors::NotFound
      false
    end

    def presigned_url(s3_key, expires_in: 3600)
      return nil if s3_key.blank?

      presigner.presigned_url(
        :get_object,
        bucket: bucket_name,
        key: s3_key,
        expires_in: expires_in
      )
    rescue StandardError => e
      Rails.logger.error "Failed to generate presigned URL for #{s3_key}: #{e.message}"
      nil
    end

    def presigned_download_url(s3_key, filename, expires_in: 3600)
      return nil if s3_key.blank?

      presigner.presigned_url(
        :get_object,
        bucket: bucket_name,
        key: s3_key,
        expires_in: expires_in,
        response_content_disposition: "attachment; filename=\"#{filename}\""
      )
    rescue StandardError => e
      Rails.logger.error "Failed to generate presigned download URL for #{s3_key}: #{e.message}"
      nil
    end

    def presigned_upload_url(s3_key, content_type: nil, expires_in: 3600)
      return nil if s3_key.blank?

      params = {
        bucket: bucket_name,
        key: s3_key,
        expires_in: expires_in
      }
      params[:content_type] = content_type if content_type.present?

      presigner.presigned_url(:put_object, params)
    rescue StandardError => e
      Rails.logger.error "Failed to generate presigned upload URL for #{s3_key}: #{e.message}"
      nil
    end

    def copy(source_key, destination_key)
      return false if source_key.blank? || destination_key.blank?

      client.copy_object(
        bucket: bucket_name,
        copy_source: "#{bucket_name}/#{source_key}",
        key: destination_key
      )

      Rails.logger.info "Successfully copied #{source_key} to #{destination_key}"
      true
    rescue StandardError => e
      Rails.logger.error "S3 copy failed from #{source_key} to #{destination_key}: #{e.message}"
      raise
    end

    def list_objects(prefix: nil, max_keys: 1000)
      params = {
        bucket: bucket_name,
        max_keys: max_keys
      }
      params[:prefix] = prefix if prefix.present?

      response = client.list_objects_v2(params)
      response.contents.map do |object|
        {
          key: object.key,
          size: object.size,
          last_modified: object.last_modified,
          etag: object.etag
        }
      end
    rescue StandardError => e
      Rails.logger.error "Failed to list objects with prefix #{prefix}: #{e.message}"
      []
    end

    def get_object_metadata(s3_key)
      return nil if s3_key.blank?

      response = client.head_object(
        bucket: bucket_name,
        key: s3_key
      )

      {
        content_type: response.content_type,
        content_length: response.content_length,
        last_modified: response.last_modified,
        etag: response.etag,
        metadata: response.metadata
      }
    rescue Aws::S3::Errors::NotFound
      nil
    rescue StandardError => e
      Rails.logger.error "Failed to get metadata for #{s3_key}: #{e.message}"
      nil
    end

    def download(s3_key)
      return nil if s3_key.blank?

      response = client.get_object(
        bucket: bucket_name,
        key: s3_key
      )

      response.body.read
    rescue StandardError => e
      Rails.logger.error "Failed to download #{s3_key}: #{e.message}"
      nil
    end

    private

    def client
      @client ||= Aws::S3::Client.new(
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key
      )
    end

    def presigner
      @presigner ||= Aws::S3::Presigner.new(client: client)
    end

    def bucket_name
      ENV.fetch('S3_BUCKET') do
        raise 'S3_BUCKET environment variable is not set'
      end
    end

    def region
      ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-west-2'
    end

    def access_key_id
      ENV.fetch('AWS_ACCESS_KEY_ID') do
        raise 'AWS_ACCESS_KEY_ID environment variable is not set'
      end
    end

    def secret_access_key
      ENV.fetch('AWS_SECRET_ACCESS_KEY') do
        raise 'AWS_SECRET_ACCESS_KEY environment variable is not set'
      end
    end

    def extract_file_content(file)
      case file
      when ActionDispatch::Http::UploadedFile
        file.tempfile.read
      when Tempfile
        file.read
      when File
        file.read
      when String
        file
      else
        file.respond_to?(:read) ? file.read : file.to_s
      end
    end

    def extract_content_type(file)
      return file.content_type if file.respond_to?(:content_type)
      
      # Fallback to MIME type detection
      filename = extract_filename(file)
      MIME::Types.type_for(filename).first&.to_s || 'application/octet-stream'
    end

    def extract_filename(file)
      return file.original_filename if file.respond_to?(:original_filename)
      return file.path if file.respond_to?(:path)
      'unknown'
    end

    def stringify_metadata(metadata)
      metadata.transform_values(&:to_s)
    end
  end
end