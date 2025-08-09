# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include JwtAuth

      def authenticate
        if params[:provider] == 'google'
          authenticate_with_google
        else
          authenticate_with_email_and_password
        end
      end

      def destroy
        if request.headers['Authorization'].nil?
          render json: { success: false, message: 'Usuário não autorizado' }, status: :unauthorized
        else
          token = request.headers['Authorization'].split.last
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

      def authenticate_with_email_and_password
        admin = Admin.find_for_authentication(email: auth_params[:email])

        if admin&.valid_password?(auth_params[:password])
          profile_admin = admin.profile_admin
          token = update_user_token(admin, profile_admin)
          
          response_data = { token: token }
          response_data[:role] = profile_admin.role if profile_admin
          response_data[:needs_profile_setup] = profile_admin.nil?
          
          render json: response_data
        else
          head :unauthorized
        end
      end

      def authenticate_with_google
        access_token = params[:accessToken]
        return head :unauthorized if access_token.blank?

        user_info = fetch_google_user_info(access_token)
        return head :unauthorized if user_info.nil?

        email = user_info['email']
        return head :unauthorized if email.blank?

        admin = Admin.find_for_authentication(email: email)

        if admin
          profile_admin = admin.profile_admin
          token = update_user_token(admin, profile_admin)
          
          response_data = { token: token }
          response_data[:role] = profile_admin.role if profile_admin
          response_data[:needs_profile_setup] = profile_admin.nil?
          
          render json: response_data
        else
          head :not_found
        end
      end

      def fetch_google_user_info(access_token)
        uri = URI('https://www.googleapis.com/oauth2/v3/tokeninfo')
        params = { access_token: access_token }
        uri.query = URI.encode_www_form(params)

        response = Net::HTTP.get_response(uri)

        return nil unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue StandardError => e
        Rails.logger.error("Error fetching Google user info: #{e.message}")
        nil
      end

      def update_user_token(admin, profile_admin)
        exp = Time.now.to_i + (24 * 3600)
        token_data = { admin_id: admin.id, exp: exp }
        
        if profile_admin
          token_data[:name] = profile_admin.name
          token_data[:last_name] = profile_admin.last_name
        else
          token_data[:email] = admin.email
        end
        
        token = JWT.encode(token_data, Rails.application.secret_key_base)
        admin.update(jwt_token: token)
        token
      end

      def auth_params
        params.require(:auth).permit(:email, :password)
      end

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
