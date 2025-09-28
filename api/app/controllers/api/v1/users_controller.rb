# frozen_string_literal: true

module Api
  module V1
    class UsersController < BackofficeController
      before_action :retrieve_user, only: [:update, :show]
      before_action :perform_authorization, unless: -> { Rails.env.development? && params[:all_teams] == 'true' }

      after_action :verify_authorized, unless: -> { Rails.env.development? && params[:all_teams] == 'true' }

      def index
        # Super admin bypass em dev mode
        users = if Rails.env.development? && params[:all_teams] == 'true'
                  User.includes(:user_profile, :team)
                else
                  team_scoped(User).includes(:user_profile)
                end

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          users = users.public_send("filter_by_#{key}", value.strip)
        end

        serialized_data = UserSerializer.new(
          users,
          meta: {
            total_count: users.offset(nil).limit(nil).count
          },
          include: [:user_profile]
        ).serializable_hash

        render json: {
          success: true,
          message: 'Usuários obtidos com sucesso',
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
        serialized_data = UserSerializer.new(
          @user,
          include: [:user_profile]
        ).serializable_hash

        render json: {
          success: true,
          message: 'Usuário obtido com sucesso',
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
        user = User.new(users_params)
        # Automaticamente atribui o team do usuário atual ao novo usuário
        user.team = current_team || @current_user.team

        if user.save
          serialized_data = UserSerializer.new(
            user,
            include: [:user_profile]
          ).serializable_hash

          render json: {
            success: true,
            message: 'Usuário criado com sucesso',
            data: serialized_data[:data]
          }, status: :created
        else
          error_messages = user.errors.full_messages
          render(
            status: :bad_request,
            json: {
              success: false,
              message: error_messages.first,
              errors: error_messages
            }
          )
        end
      rescue StandardError => e
        error_message = e.message
        render(
          status: :bad_request,
          json: {
            success: false,
            message: error_message,
            errors: [error_message]
          }
        )
      end

      def update
        if @user.update(users_params)
          serialized_data = UserSerializer.new(
            @user,
            include: [:user_profile]
          ).serializable_hash

          render json: {
            success: true,
            message: 'Usuário atualizado com sucesso',
            data: serialized_data[:data]
          }, status: :ok
        else
          error_messages = @user.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_content
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
          user = User.with_deleted.find(params[:id])
          user.destroy_fully!
          message = 'Usuário removido permanentemente'
        else
          retrieve_user
          @user.destroy
          message = 'Usuário removido com sucesso'
        end

        render json: {
          success: true,
          message: message,
          data: { id: params[:id] }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Usuário não encontrado',
          errors: ['Usuário não encontrado']
        }, status: :not_found
      rescue StandardError => e
        error_message = e.message
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :unprocessable_content
      end

      def restore
        user = User.with_deleted.find(params[:id])
        if user.recover
          serialized_data = UserSerializer.new(
            user,
            include: [:user_profile]
          ).serializable_hash

          render json: {
            success: true,
            message: 'Usuário restaurado com sucesso',
            data: serialized_data[:data]
          }, status: :ok
        else
          error_messages = user.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Usuário não encontrado',
          errors: ['Usuário não encontrado']
        }, status: :not_found
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def users_params
        params.expect(
          user: [:email, :access_email, :password,
                 :password_confirmation, :status,
                 { user_profile_attributes: [
                   :role, :status, :user_id, :office_id, :name, :last_name, :gender, :oab, :rg, :cpf, :nationality, :civil_status, :birth, :mother_name
                 ] }]
        )
      end

      def retrieve_user
        @user = team_scoped(User).find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :user], :"#{action_name}?"
      end
    end
  end
end
