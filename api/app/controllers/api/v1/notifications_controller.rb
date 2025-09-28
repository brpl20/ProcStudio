# frozen_string_literal: true

module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class NotificationsController < BackofficeController
      before_action :set_notification, only: [:show, :update, :destroy, :mark_as_read, :mark_as_unread]

      def index
        notifications = fetch_base_notifications
        notifications = apply_filters(notifications)
        paginated_notifications, pagination_meta = paginate_notifications(notifications)
        render_notifications_index(paginated_notifications, pagination_meta)
      rescue StandardError => e
        render_error_response(e)
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
        render_error_response(e)
      end

      def create
        authorize Notification
        notification = build_notification
        create_notification_response(notification)
      rescue StandardError => e
        render_error_response(e)
      end

      def update
        authorize @notification
        update_notification_response
      rescue StandardError => e
        render_error_response(e)
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

      def fetch_base_notifications
        @current_user.user_profile.notifications
          .for_team(current_team)
          .includes(:sender)
          .recent
      end

      def paginate_notifications(notifications)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 25).to_i
        total_count = notifications.count
        offset = (page - 1) * per_page

        paginated = notifications.limit(per_page).offset(offset)
        pagination_meta = build_pagination_meta(total_count, per_page, page)

        [paginated, pagination_meta]
      end

      def build_pagination_meta(total_count, per_page, page)
        {
          total_count: total_count,
          total_pages: (total_count.to_f / per_page).ceil,
          current_page: page,
          unread_count: @current_user.user_profile.notifications.for_team(current_team).unread.count
        }
      end

      def render_notifications_index(notifications, pagination_meta)
        serialized_data = NotificationSerializer.new(notifications, meta: pagination_meta).serializable_hash

        render json: {
          success: true,
          message: 'Notificações obtidas com sucesso',
          data: serialized_data[:data],
          meta: serialized_data[:meta]
        }, status: :ok
      end

      def build_notification
        notification = determine_recipient_and_build_notification
        notification.team = current_team
        notification.sender ||= @current_user.user_profile
        notification
      end

      def determine_recipient_and_build_notification
        if params[:notification][:user_profile_id].present?
          user_profile = UserProfile.find(params[:notification][:user_profile_id])
          authorize_recipient(user_profile)
          user_profile.notifications.build(notification_params)
        else
          @current_user.user_profile.notifications.build(notification_params)
        end
      end

      def create_notification_response(notification)
        if notification.save
          render_notification_success(notification, 'Notificação criada com sucesso', :created)
        else
          render_notification_error(
            'Erro ao criar notificação',
            notification.errors.full_messages,
            :unprocessable_content
          )
        end
      end

      def update_notification_response
        if @notification.update(notification_params)
          render_notification_success(@notification, 'Notificação atualizada com sucesso', :ok)
        else
          render_notification_error(
            'Erro ao atualizar notificação',
            @notification.errors.full_messages,
            :unprocessable_content
          )
        end
      end

      def render_notification_success(notification, message, status)
        serialized_data = NotificationSerializer.new(notification).serializable_hash

        render json: {
          success: true,
          message: message,
          data: serialized_data[:data]
        }, status: status
      end

      def render_notification_error(message, errors, status)
        render json: {
          success: false,
          message: message,
          errors: errors
        }, status: status
      end

      def render_error_response(error)
        render json: {
          success: false,
          message: error.message,
          errors: [error.message]
        }, status: :internal_server_error
      end

      def apply_read_filter(notifications)
        return notifications if params[:read].blank?

        params[:read] == 'true' ? notifications.where(read: true) : notifications.unread
      end

      def apply_type_filter(notifications)
        return notifications if params[:notification_type].blank?

        notifications.where(notification_type: params[:notification_type])
      end

      def apply_date_range_filter(notifications)
        notifications = notifications.where(created_at: (params[:from_date])..) if params[:from_date].present?
        notifications = notifications.where(created_at: ..(params[:to_date])) if params[:to_date].present?
        notifications
      end

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
        notifications = apply_read_filter(notifications)
        notifications = apply_type_filter(notifications)
        apply_date_range_filter(notifications)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
