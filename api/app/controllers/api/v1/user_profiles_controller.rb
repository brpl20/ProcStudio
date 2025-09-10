# frozen_string_literal: true

module Api
  module V1
    class UserProfilesController < BackofficeController
      before_action :retrieve_user_profile, only: [:update, :show]
      before_action :retrieve_deleted_user_profile, only: [:restore]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        # Super admin vê todos os perfis, outros usuários veem apenas do seu team
        user_profiles = if super_admin_access?
                          UserProfile.includes(:user)
                        else
                          UserProfile.joins(:user).where(users: { team: current_team }).includes(:user)
                        end

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          user_profiles = user_profiles.public_send("filter_by_#{key}", value.strip)
        end

        serialized_data = UserProfileSerializer.new(
          user_profiles,
          meta: {
            total_count: user_profiles.offset(nil).limit(nil).count
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Perfis de usuário obtidos com sucesso',
          data: serialized_data[:data],
          meta: serialized_data[:meta]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def show
        serialized_data = UserProfileSerializer.new(
          @user_profile,
          params: { action: 'show' }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Perfil de usuário obtido com sucesso',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def create
        profile_params = user_profiles_params

        # If user_attributes are present but user_id is not, we're creating a new user
        if profile_params[:user_attributes].present? && !profile_params[:user_id]
          user_attrs = profile_params[:user_attributes]
          user_attrs[:team_id] = current_team.id
          user_attrs[:access_email] ||= user_attrs[:email]

          # Build the user first
          user = User.new(user_attrs)
          profile_params.delete(:user_attributes)

          # Build the profile with the user
          user_profile = user.build_user_profile(profile_params)
        else
          user_profile = UserProfile.new(profile_params)

          # If creating a new user through nested attributes, set the team
          if user_profile.user&.new_record?
            user_profile.user.team_id = current_team.id
            user_profile.user.access_email = user_profile.user.email
          end
        end

        if user_profile.save
          # Reload to ensure all associations are loaded
          user_profile.reload

          serialized_data = UserProfileSerializer.new(
            user_profile,
            params: { action: 'show' }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Perfil de usuário criado com sucesso',
            data: serialized_data[:data]
          }, status: :created
        else
          error_messages = user_profile.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        error_message = e.message
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :unprocessable_entity
      end

      def update
        if @user_profile.update(user_profiles_params)
          serialized_data = UserProfileSerializer.new(
            @user_profile,
            params: { action: 'show' }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Perfil de usuário atualizado com sucesso',
            data: serialized_data[:data]
          }, status: :ok
        else
          error_messages = @user_profile.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def destroy
        if destroy_fully?
          user_profile = UserProfile.with_deleted.find(params[:id])
          user_profile.destroy_fully!
          message = 'Perfil de usuário removido permanentemente'
        else
          retrieve_user_profile
          @user_profile.destroy
          message = 'Perfil de usuário removido com sucesso'
        end

        render json: {
          success: true,
          message: message,
          data: { id: params[:id] }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Perfil de usuário não encontrado',
          errors: ['Perfil de usuário não encontrado']
        }, status: :not_found
      rescue StandardError => e
        error_message = e.message
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :unprocessable_entity
      end

      def restore
        if @user_profile.recover
          serialized_data = UserProfileSerializer.new(
            @user_profile,
            params: { action: 'show' }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Perfil de usuário restaurado com sucesso',
            data: serialized_data[:data]
          }, status: :ok
        else
          error_messages = @user_profile.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Perfil de usuário não encontrado',
          errors: ['Perfil de usuário não encontrado']
        }, status: :not_found
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def complete_profile
        # Autorizar explicitamente para este método
        authorize :user_profile, :complete?

        user = @current_user
        user_profile = user.user_profile

        # Se não existe user_profile, criar um novo
        user_profile = user.build_user_profile if user_profile.nil?

        ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
          # Atualizar dados básicos do profile
          basic_params = profile_completion_params.except(:phone, :addresses_attributes, :phones_attributes)
          user_profile.update!(basic_params) if basic_params.present?

          # Lidar com telefone legacy (campo único)
          phone_number = params.dig(:user_profile, :phone)
          create_or_update_phone(user_profile, phone_number) if phone_number.present?

          # Lidar com phones_attributes (nested)
          phones_attrs = params.dig(:user_profile, :phones_attributes)
          if phones_attrs.present?
            phones_attrs.each do |phone_attr|
              create_or_update_phone(user_profile, phone_attr[:phone_number])
            end
          end

          # Lidar com addresses_attributes (nested) - using polymorphic association
          addresses_attrs = params.dig(:user_profile, :addresses_attributes)
          if addresses_attrs.present?
            addresses_attrs.each do |address_attr|
              user_profile.addresses.create!(
                street: address_attr[:street],
                number: address_attr[:number],
                neighborhood: address_attr[:neighborhood],
                city: address_attr[:city],
                state: address_attr[:state],
                zip_code: address_attr[:zip_code],
                complement: address_attr[:description],
                address_type: 'main'
              )
            end
          end

          render json: {
            success: true,
            message: 'Perfil completado com sucesso!',
            data: UserProfileSerializer.new(user_profile).serializable_hash
          }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        error_messages = e.record.errors.full_messages
        render json: {
          success: false,
          message: error_messages.first,
          errors: error_messages
        }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Error completing profile: #{e.message}"
        render json: {
          success: false,
          message: 'Erro interno do servidor',
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def user_profiles_params
        params.require(:user_profile).permit(
          :role, :status, :user_id, :office_id, :name, :last_name, :gender, :oab,
          :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :origin,
          user_attributes: [:id, :email, :access_email, :password, :password_confirmation],
          office_attributes: [:name, :cnpj],
          addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city,
                                 :state, :complement, :address_type],
          bank_accounts_attributes: [:id, :bank_name, :type_account, :agency, :account, :operation, :pix],
          phones_attributes: [:id, :phone_number]
        )
        # rubocop:enable Rails/StrongParametersExpect
      end

      def retrieve_user_profile
        # Super admin pode acessar qualquer perfil
        @user_profile = if super_admin_access?
                          UserProfile.find(params[:id])
                        else
                          UserProfile.joins(:user).where(users: { team: current_team }).find(params[:id])
                        end
      end

      def retrieve_deleted_user_profile
        # Super admin pode acessar qualquer perfil deletado
        @user_profile = if super_admin_access?
                          UserProfile.with_deleted.find(params[:id])
                        else
                          UserProfile.with_deleted.joins(:user).where(users: { team: current_team }).find(params[:id])
                        end
      end

      def profile_completion_params
        params.expect(user_profile: [:name, :last_name, :role, :oab, :cpf, :rg, :gender, :civil_status,
                                     :nationality, :birth, :phone,
                                     { addresses_attributes: [:description, :zip_code, :street, :number,
                                                              :neighborhood, :city, :state],
                                       phones_attributes: [:phone_number] }])
      end

      def create_or_update_phone(user_profile, phone_number)
        # Limpa o telefone (remove formatação)
        clean_phone = phone_number.gsub(/\D/, '')

        # Verifica se já existe um telefone (usando polymorphic association)
        existing_phone = user_profile.phones.first

        if existing_phone
          # Atualiza o telefone existente
          existing_phone.update!(phone_number: clean_phone)
        else
          # Cria novo telefone diretamente pela associação polimórfica
          user_profile.phones.create!(
            phone_number: clean_phone
          )
        end
      end

      def perform_authorization
        # Skip authorization for complete_profile since it has explicit authorization
        return if action_name == 'complete_profile'

        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
