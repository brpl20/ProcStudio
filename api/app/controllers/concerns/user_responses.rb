# frozen_string_literal: true

module UserResponses
  extend ActiveSupport::Concern

  private

  def render_users_success(data:, meta: nil)
    response = {
      success: true,
      message: 'Usuários obtidos com sucesso',
      data: data
    }
    response[:meta] = meta if meta
    render json: response, status: :ok
  end

  def render_user_success(data:, message:, status: :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_user_error(errors:, message: nil, status: :unprocessable_content)
    render json: {
      success: false,
      message: message || errors.first,
      errors: errors
    }, status: status
  end

  def render_not_found_error
    render json: {
      success: false,
      message: 'Usuário não encontrado',
      errors: ['Usuário não encontrado']
    }, status: :not_found
  end

  def render_internal_error(error)
    render json: {
      success: false,
      message: error.message,
      errors: [error.message]
    }, status: :internal_server_error
  end
end
