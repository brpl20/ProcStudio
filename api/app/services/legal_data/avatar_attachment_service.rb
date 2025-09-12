# frozen_string_literal: true

require 'aws-sdk-s3'

class LegalData::AvatarAttachmentService
  include HTTParty

  def initialize
    @s3_client = Aws::S3::Client.new(region: 'us-west-2')
  end

  def attach_from_s3_url(user_profile, s3_url)
    return false if s3_url.blank? || user_profile.blank?

    Rails.logger.info "Attempting to attach avatar from S3 URL: #{s3_url}"

    # Parse S3 URL to extract bucket and key
    uri = URI(s3_url)
    bucket_name = uri.host.split('.')[0] # Extract bucket name from subdomain
    object_key = uri.path[1..-1] # Remove leading slash

    # Download image from S3
    s3_response = @s3_client.get_object(bucket: bucket_name, key: object_key)
    image_data = s3_response.body.read

    # Extract filename from the object key
    filename = File.basename(object_key)
    content_type = s3_response.content_type || 'image/jpeg'

    # Attach to user profile avatar
    user_profile.avatar.attach(
      io: StringIO.new(image_data),
      filename: filename,
      content_type: content_type
    )

    Rails.logger.info "Successfully attached avatar for user_profile #{user_profile.id}"
    true

  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error "AWS S3 Error attaching avatar: #{e.message}"
    false
  rescue StandardError => e
    Rails.logger.error "Error attaching avatar from S3: #{e.message}"
    false
  end

  def attach_from_http_url(user_profile, image_url)
    return false if image_url.blank? || user_profile.blank?

    Rails.logger.info "Attempting to attach avatar from HTTP URL: #{image_url}"

    response = HTTParty.get(image_url, timeout: 10)
    
    unless response.success?
      Rails.logger.error "Failed to download image: HTTP #{response.code}"
      return false
    end

    # Extract filename from URL or generate one
    filename = extract_filename_from_url(image_url) || 'profile_picture.jpg'
    content_type = response.headers['Content-Type'] || 'image/jpeg'

    # Attach to user profile avatar
    user_profile.avatar.attach(
      io: StringIO.new(response.body),
      filename: filename,
      content_type: content_type
    )

    Rails.logger.info "Successfully attached avatar for user_profile #{user_profile.id}"
    true

  rescue StandardError => e
    Rails.logger.error "Error attaching avatar from HTTP: #{e.message}"
    false
  end

  def attach_from_url(user_profile, image_url)
    return false if image_url.blank? || user_profile.blank?

    # Determine if it's an S3 URL or regular HTTP URL
    if s3_url?(image_url)
      attach_from_s3_url(user_profile, image_url)
    else
      attach_from_http_url(user_profile, image_url)
    end
  end

  private

  def s3_url?(url)
    uri = URI(url)
    uri.host&.include?('.s3.') || uri.host&.include?('s3-') || uri.host&.end_with?('.amazonaws.com')
  rescue URI::InvalidURIError
    false
  end

  def extract_filename_from_url(url)
    uri = URI(url)
    filename = File.basename(uri.path)
    filename.present? ? filename : nil
  rescue URI::InvalidURIError
    nil
  end
end