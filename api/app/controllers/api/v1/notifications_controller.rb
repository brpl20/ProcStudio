# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class NotificationsController < BackofficeController
      before_action :set_notification, only: [:show, :update, :destroy, :mark_as_read, :mark_as_unread]

      def index
        notifications = @current_user.user_profile.notifications
                          .for_team(current_team)
                          .includes(:sender)
                          .recent

        notifications = apply_filters(notifications)

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 25).to_i

        total_count = notifications.count
        offset = (page - 1) * per_page

        notifications = notifications.limit(per_page).offset(offset)

        serialized_data = NotificationSerializer.new(
          notifications,
          meta: {
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil,
            current_page: page,
            unread_count: @current_user.user_profile.notifications.for_team(current_team).unread.count
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Notificações obtidas com sucesso',
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
        authorize @notification

        serialized_data = NotificationSerializer.new(@notification).serializable_hash

        render json: {
          success: true,
          message: 'Notificação obtida com sucesso',
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
        authorize Notification

        # Allow specifying a recipient, or default to current user
        if params[:notification][:user_profile_id].present?
          user_profile = UserProfile.find(params[:notification][:user_profile_id])
          # Check if user can send notifications to this profile (same team, admin, etc.)
          authorize_recipient(user_profile)
          notification = user_profile.notifications.build(notification_params)
        else
          notification = @current_user.user_profile.notifications.build(notification_params)
        end

        # Set team and sender
        notification.team = current_team
        notification.sender ||= @current_user.user_profile

        if notification.save
          serialized_data = NotificationSerializer.new(notification).serializable_hash

          render json: {
            success: true,
            message: 'Notificação criada com sucesso',
            data: serialized_data[:data]
          }, status: :created
        else
          render json: {
            success: false,
            message: 'Erro ao criar notificação',
            errors: notification.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def update
        authorize @notification

        if @notification.update(notification_params)
          serialized_data = NotificationSerializer.new(@notification).serializable_hash

          render json: {
            success: true,
            message: 'Notificação atualizada com sucesso',
            data: serialized_data[:data]
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao atualizar notificação',
            errors: @notification.errors.full_messages
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
        authorize @notification

        if @notification.destroy
          render json: {
            success: true,
            message: 'Notificação removida com sucesso'
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao remover notificação',
            errors: @notification.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def mark_as_read
        authorize @notification, :update?

        @notification.mark_as_read!
        serialized_data = NotificationSerializer.new(@notification).serializable_hash

        render json: {
          success: true,
          message: 'Notificação marcada como lida',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def mark_as_unread
        authorize @notification, :update?

        @notification.mark_as_unread!
        serialized_data = NotificationSerializer.new(@notification).serializable_hash

        render json: {
          success: true,
          message: 'Notificação marcada como não lida',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def mark_all_as_read
        authorize Notification

        @current_user.user_profile.notifications.for_team(current_team).unread.update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

        render json: {
          success: true,
          message: 'Todas as notificações marcadas como lidas'
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def unread_count
        authorize Notification, :index?

        count = @current_user.user_profile.notifications.for_team(current_team).unread.count

        render json: {
          success: true,
          message: 'Contagem obtida com sucesso',
          data: { unread_count: count }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def set_notification
        @notification = @current_user.user_profile.notifications.for_team(current_team).find(params[:id])
      end

      def notification_params
        params.require(:notification).permit(
          :title,
          :body,
          :notification_type,
          :action_url,
          :sender_type,
          :sender_id,
          :user_profile_id,
          data: {}
        )
      end

      def authorize_recipient(user_profile)
        # Check if current user can send notifications to this profile
        # Allow if: same team
        return if same_team?(user_profile)

        raise Pundit::NotAuthorizedError, 'Você não pode enviar notificações para este usuário'
      end

      def same_team?(user_profile)
        @current_user.team_id == user_profile.user.team_id
      end

      def apply_filters(notifications)
        if params[:read].present?
          notifications = params[:read] == 'true' ? notifications.where(read: true) : notifications.unread
        end

        if params[:notification_type].present?
          notifications = notifications.where(notification_type: params[:notification_type])
        end

        # Priority filter removed as priority field no longer exists

        notifications = notifications.where(created_at: (params[:from_date])..) if params[:from_date].present?

        notifications = notifications.where(created_at: ..(params[:to_date])) if params[:to_date].present?

        notifications
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
