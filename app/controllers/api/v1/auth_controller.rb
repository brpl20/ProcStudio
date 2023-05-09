# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include JwtAuth
      skip_before_action :verify_authenticity_token

      def authenticate
        admin = Admin.find_for_authentication(email: params[:email])
        if admin&.valid_password?(params[:password])
          exp = Time.now.to_i + 24 * 3600
          token = JWT.encode({ admin_id: admin.id, exp: exp }, Rails.application.secret_key_base)
          admin.update(jwt_token: token)
          render json: { token: token }
        else
          head :unauthorized
        end
      end

      def destroy
        if request.headers['Authorization'].nil?
          render json: { success: false, message: 'Usuário não autorizado' }, status: :unauthorized
        else
          token = request.headers['Authorization'].split(' ').last
          decoded_token = decode_jwt_token(token)

          if decoded_token.nil?
            render json: { success: false, message: 'Usuário não autorizado' }, status: :unauthorized
          else
            admin_id = decoded_token['admin_id']
            current_admin = Admin.find(admin_id)
            current_admin.update_attribute(:jwt_token, nil)
            render json: { success: true, message: 'Saiu com successo' }
          end
        end
      end

      private

      def decode_jwt_token(token)
        secret_key = Rails.application.secrets.secret_key_base
        decoded_token = JWT.decode(token, secret_key)[0]
        HashWithIndifferentAccess.new decoded_token
      rescue JWT::DecodeError
        # puts "Error decoding JWT token: #{e.message}"
        nil
      end
    end
  end
end
