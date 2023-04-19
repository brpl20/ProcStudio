# frozen_string_literal: true

module JwtAuth
  def authenticate_admin
    token = request.headers['Authorization']&.split(' ')&.last
    payload, _header = decode_token(token)

    @current_admin ||= Admin.find(payload['admin_id'])
    head :unauthorized unless @current_admin&.jwt_token == token
    head :unauthorized unless valid_token?(token)
  rescue JWT::DecodeError
    head :unauthorized
  end

  def decode_jwt_token(token)
    secret_key = Rails.application.secrets.secret_key_base
    decoded_token = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new decoded_token
  rescue JWT::DecodeError
    nil
  end

  private

  def decode_token(token)
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
  end

  def valid_token?(token)
    payload, _header = decode_token(token)
    Time.now.to_i < payload['exp']
  rescue JWT::DecodeError
    false
  end
end
