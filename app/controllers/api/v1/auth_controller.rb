# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
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
            user_id = decoded_token['user_id'] || decoded_token['admin_id'] # backward compatibility
            current_user = User.find(user_id)
            current_user.update_attribute(:jwt_token, nil)
            render json: { success: true, message: I18n.t('errors.messages.authentication.logout_success') }
          end
        end
      end

      private

      def authenticate_with_email_and_password
        user = User.find_for_authentication(email: auth_params[:email])
        if user&.valid_password?(auth_params[:password])
          user_profile = user.user_profile
          token = update_user_token(user, user_profile)

          response_data = build_auth_response(token, user_profile)
          render json: response_data
        else
          render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') },
                 status: :unauthorized
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

        token = JWT.encode(token_data, Rails.application.secret_key_base)
        user.update(jwt_token: token)
        token
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

        # Pega o user do token decodificado
        user_id = decode_jwt_token(token)['user_id'] || decode_jwt_token(token)['admin_id']
        user = User.find(user_id)

        if user_profile.nil?
          response[:needs_profile_completion] = true
          response[:missing_fields] = required_profile_fields
          response[:oab] = user.oab if user.oab.present?
          response[:message] = I18n.t('errors.messages.profile.incomplete')
        else
          incomplete_fields = check_profile_completeness(user_profile)

          if incomplete_fields.any?
            response[:needs_profile_completion] = true
            response[:missing_fields] = incomplete_fields
            response[:message] = I18n.t('errors.messages.profile.incomplete')
          else
            response[:needs_profile_completion] = false
          end

          response[:role] = user_profile.role
          response[:name] = user_profile.name
          response[:last_name] = user_profile.last_name
          response[:oab] = user_profile.oab if user_profile.lawyer? && user_profile.oab.present?
        end

        response
      end

      def check_profile_completeness(user_profile)
        missing_fields = []

        # Campos obrigatórios básicos
        missing_fields << :name if user_profile.name.blank?
        missing_fields << :last_name if user_profile.last_name.blank?
        missing_fields << :cpf if user_profile.cpf.blank?
        missing_fields << :rg if user_profile.rg.blank?
        missing_fields << :role if user_profile.role.blank?
        missing_fields << :gender if user_profile.gender.blank?
        missing_fields << :civil_status if user_profile.civil_status.blank?
        missing_fields << :nationality if user_profile.nationality.blank?
        missing_fields << :birth if user_profile.birth.blank?

        # OAB obrigatório apenas para advogados
        missing_fields << :oab if user_profile.lawyer? && user_profile.oab.blank?

        # Verificar se tem pelo menos um telefone e email
        missing_fields << :phone if user_profile.phones.empty?
        missing_fields << :address if user_profile.addresses.empty?

        missing_fields
      end

      def required_profile_fields
        [:name, :last_name, :cpf, :rg, :role, :gender, :civil_status, :nationality, :birth, :phone, :address]
      end
    end
  end
end
