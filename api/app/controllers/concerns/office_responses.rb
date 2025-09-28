# frozen_string_literal: true

module OfficeResponses
  extend ActiveSupport::Concern

  private

  def office_success_response(message, data = nil, status = :ok)
    response = {
      success: true,
      message: message
    }
    response[:data] = data if data
    render json: response, status: status
  end

  def office_error_response(message, errors = nil, status = :unprocessable_content)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def office_upload_success_response(office, message)
    serialized = OfficeSerializer.new(
      office,
      { params: { action: 'show' } }
    ).serializable_hash

    office_success_response(message, serialized[:data])
  end

  def office_upload_error_response(service_result)
    if service_result.respond_to?(:errors) && service_result.errors.any?
      office_error_response(service_result.message, service_result.errors)
    else
      office_error_response(service_result.message)
    end
  end

  def office_internal_error_response(error, message)
    Rails.logger.error "#{message}: #{error.message}"
    Rails.logger.error error.backtrace.first(10).join("\n") if error.backtrace
    office_error_response(message, [error.message], :internal_server_error)
  end
end
