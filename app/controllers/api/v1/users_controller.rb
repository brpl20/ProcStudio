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

        render json: UserSerializer.new(
          users,
          meta: {
            total_count: users.offset(nil).limit(nil).count
          },
          include: [:user_profile]
        ), status: :ok
      end

      def show
        render json: UserSerializer.new(
          @user,
          include: [:user_profile]
        ), status: :ok
      end

      def create
        user = User.new(users_params)
        if user.save
          render json: UserSerializer.new(
            user
          ), status: :created
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
          render json: UserSerializer.new(
            @user
          ), status: :ok
        else
          error_messages = @user.errors.full_messages
          render(
            status: :bad_request,
            json: {
              success: false,
              message: error_messages.first,
              errors: error_messages
            }
          )
        end
      end

      def destroy
        if destroy_fully?
          User.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_user
          @user.destroy
        end
      end

      def restore
        user = User.with_deleted.find(params[:id])
        if user.recover
          render json: UserSerializer.new(
            user
          ), status: :ok
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
