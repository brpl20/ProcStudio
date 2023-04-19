# frozen_string_literal: true

module JwtAuth
  def authenticate_admin
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
    @current_admin ||= Admin.find(payload[0]['admin_id'])
  rescue JWT::DecodeError
    head :unauthorized
  end
end
