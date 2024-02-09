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

  def authenticate_customer
    token = request.headers['Authorization']&.split(' ')&.last
    payload, _header = decode_token(token)

    @current_customer ||= customer.find(payload['customer_id'])
    head :unauthorized unless @current_customer&.jwt_token == token
    head :unauthorized unless valid_token?(token)
  rescue JWT::DecodeError
    head :unauthorized
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
