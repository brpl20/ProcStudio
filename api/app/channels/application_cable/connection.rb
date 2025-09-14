# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params['token'] || request.headers['Authorization']&.split(' ')&.last
      
      if token
        decoded_token = decode_jwt(token)
        if decoded_token && (user = User.find_by(id: decoded_token['user_id']))
          user
        else
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
      reject_unauthorized_connection
    end

    def decode_jwt(token)
      JWT.decode(
        token,
        Rails.application.credentials.jwt_secret,
        true,
        { algorithm: 'HS256' }
      ).first
    rescue StandardError
      nil
    end
  end
end
