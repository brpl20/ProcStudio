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
          render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') }, status: :unauthorized
        else
          token = request.headers['Authorization'].split.last
          decoded_token = decode_jwt_token(token)

          if decoded_token.nil?
            render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') }, status: :unauthorized
          else
            admin_id = decoded_token['admin_id']
            current_admin = Admin.find(admin_id)
            current_admin.update_attribute(:jwt_token, nil)
            render json: { success: true, message: I18n.t('errors.messages.authentication.logout_success') }
          end
        end
      end

      private

      def authenticate_with_email_and_password
        admin = Admin.find_for_authentication(email: auth_params[:email])
        if admin&.valid_password?(auth_params[:password])
          profile_admin = admin.profile_admin
          token = update_user_token(admin, profile_admin)

          response_data = build_auth_response(token, profile_admin)
          render json: response_data
        else
          render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') }, status: :unauthorized
        end
      end

      def update_user_token(admin, profile_admin)
        exp = Time.now.to_i + (24 * 3600)
        token_data = {
          admin_id: admin.id,
          exp: exp
        }

        if profile_admin
          token_data[:name] = profile_admin.name
          token_data[:last_name] = profile_admin.last_name
          token_data[:role] = profile_admin.role
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

      def build_auth_response(token, profile_admin)
        response = { token: token }

        # Pega o admin do token decodificado
        admin = Admin.find(decode_jwt_token(token)['admin_id'])

        if profile_admin.nil?
          response[:needs_profile_completion] = true
          response[:missing_fields] = required_profile_fields
          response[:oab] = admin.oab if admin.oab.present?
          response[:message] = I18n.t('errors.messages.profile.incomplete')
        else
          incomplete_fields = check_profile_completeness(profile_admin)

          if incomplete_fields.any?
            response[:needs_profile_completion] = true
            response[:missing_fields] = incomplete_fields
            response[:message] = I18n.t('errors.messages.profile.incomplete')
          else
            response[:needs_profile_completion] = false
          end

          response[:role] = profile_admin.role
          response[:name] = profile_admin.name
          response[:last_name] = profile_admin.last_name
          response[:oab] = profile_admin.oab if profile_admin.lawyer? && profile_admin.oab.present?
        end

        response
      end

      def check_profile_completeness(profile_admin)
        missing_fields = []

        # Campos obrigatórios básicos
        missing_fields << :name if profile_admin.name.blank?
        missing_fields << :last_name if profile_admin.last_name.blank?
        missing_fields << :cpf if profile_admin.cpf.blank?
        missing_fields << :rg if profile_admin.rg.blank?
        missing_fields << :role if profile_admin.role.blank?
        missing_fields << :gender if profile_admin.gender.blank?
        missing_fields << :civil_status if profile_admin.civil_status.blank?
        missing_fields << :nationality if profile_admin.nationality.blank?
        missing_fields << :birth if profile_admin.birth.blank?

        # OAB obrigatório apenas para advogados
        if profile_admin.lawyer?
          missing_fields << :oab if profile_admin.oab.blank?
        end

        # Verificar se tem pelo menos um telefone e email
        missing_fields << :phone if profile_admin.phones.empty?
        missing_fields << :address if profile_admin.addresses.empty?

        missing_fields
      end

      def required_profile_fields
        [:name, :last_name, :cpf, :rg, :role, :gender, :civil_status, :nationality, :birth, :phone, :address]
      end
    end
  end
end

      private

      def authenticate_with_email_and_password
        admin = Admin.find_for_authentication(email: auth_params[:email])
        if admin&.valid_password?(auth_params[:password])
          profile_admin = admin.profile_admin
          token = update_user_token(admin, profile_admin)

          response_data = build_auth_response(token, profile_admin)
          render json: response_data
        else
          render json: { success: false, message: I18n.t('errors.messages.authentication.unauthorized') }, status: :unauthorized
        end
      end

      def update_user_token(admin, profile_admin)
        exp = Time.now.to_i + (24 * 3600)
        token_data = {
          admin_id: admin.id,
          exp: exp
        }

        if profile_admin
          token_data[:name] = profile_admin.name
          token_data[:last_name] = profile_admin.last_name
          token_data[:role] = profile_admin.role
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

      def build_auth_response(token, profile_admin)
        response = { token: token }

        # Pega o admin do token decodificado
        admin = Admin.find(decode_jwt_token(token)['admin_id'])

        if profile_admin.nil?
          response[:needs_profile_completion] = true
          response[:missing_fields] = required_profile_fields
          response[:oab] = admin.oab if admin.oab.present?
          response[:message] = I18n.t('errors.messages.profile.incomplete')
        else
          incomplete_fields = check_profile_completeness(profile_admin)

          if incomplete_fields.any?
            response[:needs_profile_completion] = true
            response[:missing_fields] = incomplete_fields
            response[:message] = I18n.t('errors.messages.profile.incomplete')
          else
            response[:needs_profile_completion] = false
          end

          response[:role] = profile_admin.role
          response[:name] = profile_admin.name
          response[:last_name] = profile_admin.last_name
          response[:oab] = profile_admin.oab if profile_admin.lawyer? && profile_admin.oab.present?
        end

        response
      end

      def check_profile_completeness(profile_admin)
        missing_fields = []

        # Campos obrigatórios básicos
        missing_fields << :name if profile_admin.name.blank?
        missing_fields << :last_name if profile_admin.last_name.blank?
        missing_fields << :cpf if profile_admin.cpf.blank?
        missing_fields << :rg if profile_admin.rg.blank?
        missing_fields << :role if profile_admin.role.blank?
        missing_fields << :gender if profile_admin.gender.blank?
        missing_fields << :civil_status if profile_admin.civil_status.blank?
        missing_fields << :nationality if profile_admin.nationality.blank?
        missing_fields << :birth if profile_admin.birth.blank?

        # OAB obrigatório apenas para advogados
        if profile_admin.lawyer?
          missing_fields << :oab if profile_admin.oab.blank?
        end

        # Verificar se tem pelo menos um telefone e email
        missing_fields << :phone if profile_admin.phones.empty?
        missing_fields << :address if profile_admin.addresses.empty?

        missing_fields
      end
