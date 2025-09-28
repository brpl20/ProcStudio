# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include ErrorHandler
      include JwtAuth

      def authenticate
        authenticate_with_email_and_password
      end

      def destroy
        if request.headers['Authorization'].nil?
          render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') },
                 status: :unauthorized
        else
          token = request.headers['Authorization'].split.last
          decoded_token = decode_jwt_token(token)

          if decoded_token.nil?
            render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') },
                   status: :unauthorized
          else
            # Token is stateless now, so we just return success
            # The frontend will clear the token from local storage
            render json: { success: true, message: I18n.t('errors.messages.authentication.logout_success') }
          end
        end
      end

      private

      def authenticate_with_email_and_password
        user = User.find_for_authentication(email: auth_params[:email])
        if user&.valid_password?(auth_params[:password])
          # Recarregar user para garantir que temos a versão mais atual com user_profile
          user.reload
          user_profile = user.user_profile
          token = update_user_token(user, user_profile)

          response_data = build_auth_response(token, user_profile)
          render json: {
            success: true,
            message: response_data[:message] || 'Login realizado com sucesso',
            data: response_data
          }
        else
          render json: {
            success: false,
            message: I18n.t('errors.messages.authentication.unauthorized'),
            errors: [I18n.t('errors.messages.authentication.unauthorized')]
          }, status: :unauthorized
        end
      end

      def update_user_token(user, user_profile)
        exp = Time.now.to_i + (24 * 3600)
        token_data = {
          user_id: user.id,
          admin_id: user.id, # backward compatibility
          exp: exp
        }

        if user_profile
          token_data[:name] = user_profile.name
          token_data[:last_name] = user_profile.last_name
          token_data[:role] = user_profile.role
        end

        JWT.encode(token_data, Rails.application.secret_key_base)
      end

      def auth_params
        params.expect(auth: [:email, :password])
      end

      def decode_jwt_token(token)
        secret_key = Rails.application.secret_key_base
        decoded_token = JWT.decode(token, secret_key)[0]
        ActiveSupport::HashWithIndifferentAccess.new decoded_token
      rescue JWT::DecodeError
        # puts "Error decoding JWT token: #{e.message}"
        nil
      end

      def build_auth_response(token, user_profile)
        response = { token: token }
        user = extract_user_from_token(token)

        if user_profile.nil?
          build_incomplete_profile_response(response, user)
        else
          build_complete_profile_response(response, user_profile)
        end

        response
      end

      def check_profile_completeness(user_profile)
        missing_fields = []
        missing_fields.concat(check_basic_fields(user_profile))
        missing_fields.concat(check_lawyer_fields(user_profile))
        missing_fields.concat(check_contact_fields(user_profile))
        missing_fields
      end

      def required_profile_fields
        [:name, :last_name, :cpf, :rg, :role, :gender, :civil_status, :nationality, :birth, :phone, :address]
      end

      def extract_user_from_token(token)
        user_id = decode_jwt_token(token)['user_id'] || decode_jwt_token(token)['admin_id']
        User.find(user_id)
      end

      def build_incomplete_profile_response(response, user)
        response[:needs_profile_completion] = true
        response[:missing_fields] = required_profile_fields
        response[:oab] = user.oab if user.oab.present?
        response[:message] = I18n.t('errors.messages.profile.incomplete')
      end

      def build_complete_profile_response(response, user_profile)
        incomplete_fields = check_profile_completeness(user_profile)

        if incomplete_fields.any?
          response[:needs_profile_completion] = true
          response[:missing_fields] = incomplete_fields
          response[:message] = I18n.t('errors.messages.profile.incomplete')
        else
          response[:needs_profile_completion] = false
          response[:message] = 'Login realizado com sucesso'
        end

        add_profile_data(response, user_profile)
      end

      def add_profile_data(response, user_profile)
        response[:role] = user_profile.role
        response[:name] = user_profile.name
        response[:last_name] = user_profile.last_name
        response[:oab] = user_profile.oab if user_profile.lawyer? && user_profile.oab.present?
        response[:gender] = user_profile.gender if user_profile.gender.present?
      end

      def check_basic_fields(user_profile)
        basic_fields = [:name, :last_name, :cpf, :rg, :role, :gender, :civil_status, :nationality, :birth]
        basic_fields.select { |field| user_profile.send(field).blank? }
      end

      def check_lawyer_fields(user_profile)
        return [] unless user_profile.lawyer? && user_profile.oab.blank?

        [:oab]
      end

      def check_contact_fields(user_profile)
        fields = []
        fields << :phone if user_profile.phones.empty?
        fields << :address if user_profile.addresses.empty?
        fields
      end
    end
  end
end
