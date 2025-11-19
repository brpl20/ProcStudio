# frozen_string_literal: true

module Api
  module V1
    class UserProfilesController < BackofficeController
      include UserProfileResponses
      include AttachmentTransferable

      before_action :retrieve_user_profile, only: [:update, :show]
      before_action :retrieve_deleted_user_profile, only: [:restore]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        user_profiles = fetch_team_user_profiles
        user_profiles = apply_filters(user_profiles)
        render_profiles_success(user_profiles)
      rescue StandardError => e
        render_error(e.message, [e.message])
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
        user_profile = build_user_profile
        if user_profile.save
          render_create_success(user_profile)
        else
          render_create_error(user_profile)
        end
      rescue StandardError => e
        render_error(e.message, [e.message], status: :unprocessable_content)
      end

      def update
        if @user_profile.update(user_profiles_params)
          user_profile_success_response(
            'Perfil de usuário atualizado com sucesso',
            @user_profile
          )
        else
          user_profile_error_response(
            @user_profile.errors.full_messages.first,
            @user_profile.errors.full_messages
          )
        end
      rescue StandardError => e
        user_profile_internal_error_response(e)
      end

      def destroy
        message = if destroy_fully?
                    perform_full_destroy
                    'Perfil de usuário removido permanentemente'
                  else
                    perform_soft_destroy
                    'Perfil de usuário removido com sucesso'
                  end

        user_profile_destroy_response(message, params[:id])
      rescue ActiveRecord::RecordNotFound
        user_profile_not_found_response
      rescue StandardError => e
        user_profile_error_response(e.message, [e.message])
      end

      def restore
        if @user_profile.recover
          user_profile_success_response(
            'Perfil de usuário restaurado com sucesso',
            @user_profile
          )
        else
          user_profile_error_response(
            @user_profile.errors.full_messages.first,
            @user_profile.errors.full_messages
          )
        end
      rescue ActiveRecord::RecordNotFound
        user_profile_not_found_response
      rescue StandardError => e
        user_profile_internal_error_response(e)
      end

      def complete_profile
        authorize :user_profile, :complete?

        service = UserProfiles::ProfileCompletionService.new(@current_user)
        result = service.call(profile_completion_params)

        if result.success?
          render json: {
            success: true,
            message: 'Perfil completado com sucesso!',
            data: UserProfileSerializer.new(result.user_profile).serializable_hash
          }, status: :ok
        else
          user_profile_error_response(
            result.errors.first,
            result.errors
          )
        end
      rescue StandardError => e
        user_profile_internal_error_response(e, 'Erro interno do servidor')
      end

      def upload_avatar
        retrieve_user_profile

        unless params[:avatar].present?
          return render json: {
            success: false,
            message: 'Arquivo de avatar não fornecido',
            errors: ['Avatar file is required']
          }, status: :unprocessable_entity
        end

        begin
          # Upload the avatar using S3Manager
          file_metadata = @user_profile.upload_avatar(
            params[:avatar],
            user_profile: current_user.user_profile
          )

          # Return success with the avatar URL
          render json: {
            success: true,
            message: 'Avatar enviado com sucesso',
            data: {
              id: @user_profile.id,
              avatar_url: @user_profile.avatar_url,
              file_metadata_id: file_metadata.id
            }
          }, status: :ok
        rescue StandardError => e
          Rails.logger.error "Avatar upload failed: #{e.message}"
          Rails.logger.error e.backtrace.first(10).join("\n")

          render json: {
            success: false,
            message: 'Erro ao fazer upload do avatar',
            errors: [e.message]
          }, status: :internal_server_error
        end
      end

      def upload_attachment
        retrieve_user_profile

        unless params[:attachment].present?
          return user_profile_error_response(
            'Arquivo não fornecido',
            ['Attachment file is required']
          )
        end

        begin
          # Generic user profile attachment (not avatar)
          file_metadata = S3Manager.upload(
            params[:attachment],
            model: @user_profile,
            user_profile: current_user.user_profile,
            metadata: {
              description: params[:description],
              document_date: params[:document_date],
              file_type: 'profile_attachment'
            }
          )

          user_profile_success_response(
            'Anexo enviado com sucesso',
            {
              id: @user_profile.id,
              file_metadata_id: file_metadata.id,
              filename: file_metadata.filename,
              url: file_metadata.url,
              byte_size: file_metadata.byte_size,
              content_type: file_metadata.content_type
            }
          )
        rescue StandardError => e
          Rails.logger.error "UserProfile attachment upload failed: #{e.message}"
          user_profile_internal_error_response(e, 'Erro ao fazer upload do anexo')
        end
      end

      def remove_attachment
        retrieve_user_profile

        begin
          FileMetadata.where(attachable: @user_profile, id: params[:attachment_id]).destroy_all

          user_profile_success_response(
            'Anexo removido com sucesso',
            { id: @user_profile.id, attachment_id: params[:attachment_id] }
          )
        rescue ActiveRecord::RecordNotFound
          user_profile_not_found_response
        rescue StandardError => e
          user_profile_internal_error_response(e, 'Erro ao remover anexo')
        end
      end

      private

      def user_profiles_params
        params.require(:user_profile).permit(
          :role, :status, :user_id, :office_id, :name, :last_name, :gender, :oab,
          :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :origin, :avatar,
          user_attributes: [:id, :email, :access_email, :password, :password_confirmation],
          office_attributes: [:name, :cnpj],
          addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city,
                                 :state, :complement, :address_type],
          bank_accounts_attributes: [:id, :bank_name, :account_type, :agency, :account, :operation, :pix],
          phones_attributes: [:id, :phone_number]
        )
        # rubocop:enable Rails/StrongParametersExpect
      end

      def retrieve_user_profile
        # Usuários podem acessar apenas perfis do seu team
        @user_profile = UserProfile.joins(:user).where(users: { team: current_team }).find(params[:id])
      end

      def retrieve_deleted_user_profile
        # Usuários podem acessar apenas perfis deletados do seu team
        @user_profile = UserProfile.with_deleted.joins(:user).where(users: { team: current_team }).find(params[:id])
      end

      def profile_completion_params
        params.require(:user_profile).permit(
          :name, :last_name, :role, :oab, :cpf, :rg, :gender, :civil_status,
          :nationality, :birth, :phone,
          addresses_attributes: [:complement, :zip_code, :street, :number, :neighborhood, :city, :state],
          phones_attributes: [:phone_number]
        )
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

        authorize [:admin, :user], :"#{action_name}?"
      end

      def fetch_team_user_profiles
        UserProfile.joins(:user).where(users: { team: current_team }).includes(:user)
      end

      def apply_filters(user_profiles)
        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          user_profiles = user_profiles.public_send("filter_by_#{key}", value.strip)
        end
        user_profiles
      end

      def render_profiles_success(user_profiles)
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
      end

      def render_error(message, errors, status: :internal_server_error)
        render json: {
          success: false,
          message: message,
          errors: errors
        }, status: status
      end

      def build_user_profile
        profile_params = user_profiles_params

        if creating_new_user?(profile_params)
          build_profile_with_new_user(profile_params)
        else
          build_profile_with_existing_user(profile_params)
        end
      end

      def creating_new_user?(profile_params)
        profile_params[:user_attributes].present? && !profile_params[:user_id]
      end

      def build_profile_with_new_user(profile_params)
        user_attrs = profile_params[:user_attributes]
        user_attrs[:team_id] = current_team.id
        user_attrs[:access_email] ||= user_attrs[:email]

        user = User.new(user_attrs)
        profile_params.delete(:user_attributes)
        user.build_user_profile(profile_params)
      end

      def build_profile_with_existing_user(profile_params)
        user_profile = UserProfile.new(profile_params)

        if user_profile.user&.new_record?
          user_profile.user.team_id = current_team.id
          user_profile.user.access_email = user_profile.user.email
        end

        user_profile
      end

      def render_create_success(user_profile)
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
      end

      def render_create_error(user_profile)
        error_messages = user_profile.errors.full_messages
        render json: {
          success: false,
          message: error_messages.first,
          errors: error_messages
        }, status: :unprocessable_content
      end

      def perform_full_destroy
        user_profile = UserProfile.with_deleted.find(params[:id])
        user_profile.destroy_fully!
      end

      def perform_soft_destroy
        retrieve_user_profile
        @user_profile.destroy
      end
    end
  end
end
