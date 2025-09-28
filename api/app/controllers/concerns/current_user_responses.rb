# frozen_string_literal: true

module CurrentUserResponses
  extend ActiveSupport::Concern

  private

  def render_user_success(data:, message: 'Informações do usuário obtidas com sucesso')
    render json: {
      success: true,
      message: message,
      data: data
    }, status: :ok
  end

  def render_user_not_found(message: 'Usuário não encontrado')
    render json: {
      success: false,
      message: message,
      errors: [message]
    }, status: :not_found
  end

  def render_profile_not_found
    render json: {
      success: false,
      message: 'Perfil não encontrado',
      errors: ['Perfil não encontrado com o ID fornecido']
    }, status: :not_found
  end

  def render_unauthorized_access
    render json: {
      success: false,
      message: 'Acesso não autorizado',
      errors: ['Você não tem permissão para visualizar as informações deste usuário']
    }, status: :forbidden
  end

  def render_user_error(error)
    Rails.logger.error "User controller error: #{error.class} - #{error.message}"
    Rails.logger.error error.backtrace.first(10).join("\n") if error.backtrace

    render json: {
      success: false,
      message: error.message,
      errors: [error.message]
    }, status: :internal_server_error
  end
end
