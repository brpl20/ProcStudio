# frozen_string_literal: true

module InputSanitizer
  extend ActiveSupport::Concern

  included do
    before_action :sanitize_params
  end

  private

  def sanitize_params
    return unless params.respond_to?(:each)

    deep_sanitize_params(params)
  end

  def deep_sanitize_params(param_object)
    case param_object
    when ActionController::Parameters, Hash
      param_object.each do |key, value|
        param_object[key] = deep_sanitize_params(value)
      end
    when Array
      param_object.map! { |item| deep_sanitize_params(item) }
    when String
      sanitize_string(param_object)
    else
      param_object
    end
  end

  def sanitize_string(string)
    return string if string.blank?

    # Remove any script tags and their content
    sanitized = string.gsub(%r{<script\b[^<]*(?:(?!</script>)<[^<]*)*</script>}mi, '')

    # Remove any on* event handlers
    sanitized = sanitized.gsub(/\bon\w+\s*=\s*["'][^"']*["']/i, '')
    sanitized = sanitized.gsub(/\bon\w+\s*=\s*[^\s>]*/i, '')

    # Remove javascript: protocol
    sanitized = sanitized.gsub(/javascript:/i, '')

    # Remove data: protocol with script content
    sanitized = sanitized.gsub(%r{data:text/html[^,]*,}i, '')

    # Escape HTML entities for common XSS vectors
    sanitized = sanitized.gsub('<', '&lt;')
                  .gsub('>', '&gt;')
                  .gsub('"', '&quot;')
                  .gsub("'", '&#39;')
                  .gsub('/', '&#x2F;')

    # Handle special characters that might be used for XSS
    sanitized = sanitized.gsub(/[;()]/, '') if sanitized.include?('alert')

    sanitized
  end

  # Method to validate and reject requests with malicious content
  def validate_input_safety?
    if contains_xss_patterns?(params)
      render json: {
        success: false,
        message: 'Invalid input detected. Please remove any HTML or script content.',
        errors: ['Input contains potentially malicious content']
      }, status: :bad_request
      false
    else
      true
    end
  end

  def contains_xss_patterns?(param_object)
    case param_object
    when ActionController::Parameters, Hash
      param_object.values.any? { |value| contains_xss_patterns?(value) }
    when Array
      param_object.any? { |item| contains_xss_patterns?(item) }
    when String
      string_contains_xss?(param_object)
    else
      false
    end
  end

  def string_contains_xss?(string)
    xss_patterns.any? { |pattern| string.match?(pattern) } ||
      contains_alert_injection?(string)
  end

  def xss_patterns
    [
      /<script/i,
      /javascript:/i,
      /\bon\w+\s*=/i,
      %r{data:text/html}i
    ]
  end

  def contains_alert_injection?(string)
    string.include?('alert') && string.match?(/[();]/)
  end
end
