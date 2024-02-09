# frozen_string_literal: true

module JwtAuth
  def authenticate_admin
    head :unauthorized and return unless payload.key?('admin_id')

    @current_admin ||= Admin.find(payload['admin_id'])
    head :unauthorized unless @current_admin&.jwt_token == token
    head :unauthorized unless valid_token?
  rescue JWT::DecodeError
    head :unauthorized
  end

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
    @token ||= request.headers['Authorization']&.split(' ')&.last
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
