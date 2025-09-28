# frozen_string_literal: true

module ProfileCustomerResponses
  extend ActiveSupport::Concern

  private

  def profile_customer_success_response(message, profile_customer, status = :ok)
    render json: {
      success: true,
      message: message,
      data: ProfileCustomerSerializer.new(
        profile_customer,
        params: { action: 'show' }
      ).serializable_hash[:data]
    }, status: status
  end

  def profile_customer_error_response(message, errors = nil, status = :unprocessable_content)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def handle_profile_customer_create_errors(error, params)
    error_handler = ProfileCustomers::ErrorHandlerService.new(self)
    error_handler.handle_create_error(error, params)
  end

  def handle_profile_customer_update_errors(error)
    error_handler = ProfileCustomers::ErrorHandlerService.new(self)
    error_handler.handle_update_error(error)
  end
end
