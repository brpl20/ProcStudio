# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_not_destroyed
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
    rescue_from JWT::DecodeError, with: :handle_jwt_error
    rescue_from JWT::ExpiredSignature, with: :handle_jwt_expired
  end

  private

  def handle_not_found(exception)
    log_error(exception)
    render_error('Record not found', :not_found)
  end

  def handle_record_invalid(exception)
    log_error(exception)
    render_error(exception.record.errors.full_messages.join(', '), :unprocessable_entity)
  end

  def handle_not_destroyed(exception)
    log_error(exception)
    render_error('Record could not be deleted', :unprocessable_entity)
  end

  def handle_parameter_missing(exception)
    log_error(exception)
    render_error("Missing parameter: #{exception.param}", :bad_request)
  end

  def handle_unauthorized(exception)
    log_error(exception)
    render_error('You are not authorized to perform this action', :forbidden)
  end

  def handle_jwt_error(exception)
    log_error(exception)
    render_error('Invalid authentication token', :unauthorized)
  end

  def handle_jwt_expired(exception)
    log_error(exception)
    render_error('Authentication token has expired', :unauthorized)
  end

  def handle_standard_error(exception)
    log_error(exception)

    # In development/test, show the actual error
    if Rails.env.local?
      render_error(exception.message, :internal_server_error)
    else
      # In production, show a generic message
      render_error('An error occurred while processing your request', :internal_server_error)
    end
  end

  def render_error(message, status)
    render json: {
      error: {
        message: message,
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
        timestamp: Time.current.iso8601
      }
    }, status: status
  end

  def log_error(exception)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?

    # You can add external error tracking here later
    # Sentry.capture_exception(exception) if defined?(Sentry)
  end
end
