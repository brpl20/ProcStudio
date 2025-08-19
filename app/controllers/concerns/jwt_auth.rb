# frozen_string_literal: true

module JwtAuth
  def authenticate_user
    # Support both new user_id and legacy admin_id for backward compatibility
    user_id = payload['user_id'] || payload['admin_id']
    head :unauthorized and return unless user_id

    @current_user ||= User.find(user_id)
    head :unauthorized unless @current_user&.jwt_token == token
    head :unauthorized unless valid_token?
  rescue JWT::DecodeError
    head :unauthorized
  end

  # Legacy method for backward compatibility
  alias authenticate_admin authenticate_user

  def authenticate_customer
    head :unauthorized and return unless payload.key?('customer_id')

    @current_customer ||= Customer.find(payload['customer_id'])
    head :unauthorized unless @current_customer&.jwt_token == token
    head :unauthorized unless valid_token?
  rescue JWT::DecodeError
    head :unauthorized
  end

  private

  def token
    @token ||= request.headers['Authorization']&.split&.last
  end

  def decode_token
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')[0]
  end

  def payload
    @payload ||= decode_token
  end

  def valid_token?
    Time.now.to_i < payload['exp']
  rescue JWT::DecodeError
    false
  end
end
