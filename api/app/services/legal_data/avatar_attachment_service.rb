# frozen_string_literal: true

class LegalData::AvatarAttachmentService
  include HTTParty

  def attach_from_url(user_profile, image_url)
    return false unless valid_inputs?(user_profile, image_url)

    if s3_url?(image_url)
      attach_from_s3(user_profile, image_url)
    else
      attach_from_http(user_profile, image_url)
    end
  end

  private

  # Validation Methods
  def valid_inputs?(user_profile, image_url)
    return false if user_profile.blank? || image_url.blank?

    true
  end

  # S3 Attachment Methods
  def attach_from_s3(user_profile, s3_url)
    log_attachment_attempt('S3', s3_url, user_profile.id)

    s3_key = extract_s3_key(s3_url)
    image_data = download_from_s3(s3_key)

    return false unless image_data

    attach_image_to_profile(user_profile, image_data, s3_key)
  rescue StandardError => e
    log_attachment_error('S3', e.message)
    false
  end

  def extract_s3_key(s3_url)
    uri = URI(s3_url)
    uri.path[1..] # Remove leading slash
  end

  def download_from_s3(s3_key)
    image_data = S3Service.download(s3_key)

    if image_data.nil?
      log_download_failure('S3', s3_key)
      return nil
    end

    image_data
  end

  def attach_image_to_profile(user_profile, image_data, source_key)
    metadata = fetch_image_metadata(source_key)
    filename = extract_filename(source_key)

    user_profile.avatar.attach(
      io: StringIO.new(image_data),
      filename: filename,
      content_type: metadata[:content_type]
    )

    log_attachment_success(user_profile.id)
    true
  end

  def fetch_image_metadata(s3_key)
    metadata = S3Service.get_object_metadata(s3_key)
    {
      content_type: metadata&.dig(:content_type) || default_content_type
    }
  end

  # HTTP Attachment Methods
  def attach_from_http(user_profile, image_url)
    log_attachment_attempt('HTTP', image_url, user_profile.id)

    response = download_from_http(image_url)
    return false unless response

    process_http_response(user_profile, response, image_url)
  rescue StandardError => e
    log_attachment_error('HTTP', e.message)
    false
  end

  def download_from_http(image_url)
    response = HTTParty.get(image_url, timeout: 10)

    unless response.success?
      log_http_failure(response.code)
      return nil
    end

    response
  end

  def process_http_response(user_profile, response, image_url)
    attachment_params = build_http_attachment_params(response, image_url)

    user_profile.avatar.attach(attachment_params)

    log_attachment_success(user_profile.id)
    true
  end
  # rubocop:enable Naming/PredicateMethod

  def build_http_attachment_params(response, image_url)
    {
      io: StringIO.new(response.body),
      filename: extract_filename_from_url(image_url),
      content_type: response.headers['Content-Type'] || default_content_type
    }
  end

  # URL Processing Methods
  def s3_url?(url)
    uri = URI(url)
    uri.host&.include?('.s3.') ||
      uri.host&.include?('s3-') ||
      uri.host&.end_with?('.amazonaws.com')
  rescue URI::InvalidURIError
    false
  end

  def extract_filename(path)
    File.basename(path)
  end

  def extract_filename_from_url(url)
    uri = URI(url)
    filename = File.basename(uri.path)
    filename.presence || default_filename
  rescue URI::InvalidURIError
    default_filename
  end

  # Default Values
  def default_content_type
    'image/jpeg'
  end

  def default_filename
    'profile_picture.jpg'
  end

  # Logging Methods
  def log_attachment_attempt(source, url, user_profile_id)
    Rails.logger.info "Attempting to attach avatar from #{source} for user_profile #{user_profile_id}: #{url}"
  end

  def log_attachment_success(user_profile_id)
    Rails.logger.info "Successfully attached avatar for user_profile #{user_profile_id}"
  end

  def log_attachment_error(source, error_message)
    Rails.logger.error "Error attaching avatar from #{source}: #{error_message}"
  end

  def log_download_failure(source, identifier)
    Rails.logger.error "Failed to download image from #{source}: #{identifier}"
  end

  def log_http_failure(status_code)
    Rails.logger.error "Failed to download image: HTTP #{status_code}"
  end
end
