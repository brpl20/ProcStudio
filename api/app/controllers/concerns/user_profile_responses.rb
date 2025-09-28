# frozen_string_literal: true

module UserProfileResponses
  extend ActiveSupport::Concern

  private

  def user_profile_success_response(message, user_profile, status = :ok)
    serialized_data = UserProfileSerializer.new(
      user_profile,
      params: { action: 'show' }
    ).serializable_hash

    render json: {
      success: true,
      message: message,
      data: serialized_data[:data]
    }, status: status
  end

  def user_profile_error_response(message, errors = nil, status = :unprocessable_content)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def user_profile_not_found_response(message = 'Perfil de usuário não encontrado')
    user_profile_error_response(
      message,
      [message],
      :not_found
    )
  end

  def user_profile_internal_error_response(error, message = 'Erro interno do servidor')
    Rails.logger.error "UserProfile error: #{error.message}"
    user_profile_error_response(
      message,
      [error.message],
      :internal_server_error
    )
  end

  def user_profile_destroy_response(message, id)
    render json: {
      success: true,
      message: message,
      data: { id: id }
    }, status: :ok
  end
end
