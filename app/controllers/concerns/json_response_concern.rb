# frozen_string_literal: true

module JsonResponseConcern
  extend ActiveSupport::Concern

  def render_success(message:, data: nil, status: :ok, **options)
    response = {
      success: true,
      message: message
    }
    response[:data] = data if data
    response.merge!(options)

    render json: response, status: status
  end

  def render_error(message:, errors: [], status: :bad_request)
    render json: {
      success: false,
      message: message,
      errors: Array(errors)
    }, status: status
  end

  def render_not_found(resource_name = 'Recurso', custom_message = nil)
    message = custom_message || "#{resource_name} não encontrado"
    render_error(
      message: message,
      errors: [message],
      status: :not_found
    )
  end

  def render_unauthorized(custom_message = nil)
    message = custom_message || 'Acesso não autorizado'
    render_error(
      message: message,
      errors: [message],
      status: :unauthorized
    )
  end
end
