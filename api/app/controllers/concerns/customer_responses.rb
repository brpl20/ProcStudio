# frozen_string_literal: true

module CustomerResponses
  extend ActiveSupport::Concern

  private

  def render_customers_success(data:, meta: nil, included: nil)
    response = {
      success: true,
      message: 'Clientes listados com sucesso',
      data: data
    }
    response[:meta] = meta if meta
    response[:included] = included if included
    render json: response, status: :ok
  end

  def render_customer_success(data:, message:, included: nil, status: :ok)
    response = {
      success: true,
      message: message,
      data: data
    }
    response[:included] = included if included
    render json: response, status: status
  end

  def render_customer_error(errors:, message: nil, status: :unprocessable_content)
    render json: {
      success: false,
      message: message || errors.first,
      errors: errors
    }, status: status
  end

  def render_customer_server_error(message: 'Erro interno do servidor')
    render json: {
      success: false,
      message: message,
      errors: [message]
    }, status: :internal_server_error
  end
end
