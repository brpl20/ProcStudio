# frozen_string_literal: true

module Api
  module V1
    class CurrentUserController < BackofficeController
      include CurrentUserResponses

      # No authorization check needed for these endpoints
      # Users can always see their own data, and we handle team member access manually

      # GET /api/v1/whoami
      # Returns the complete information of the currently authenticated user
      def whoami
        user = CurrentUser::UserFinderService.load_with_associations(@current_user.id)
        serialized_data = FullUserSerializer.new(user).serializable_hash

        render_user_success(
          data: serialized_data[:data],
          message: 'Informações do usuário atual obtidas com sucesso'
        )
      rescue StandardError => e
        render_user_error(e)
      end

      # GET /api/v1/user_info/:identifier
      # Returns complete user information by User ID or UserProfile ID
      # @param identifier can be either a User ID or UserProfile ID
      # @param type (optional) specifies if identifier is 'user_id' or 'profile_id'
      def user_info
        user = CurrentUser::UserFinderService.find_by_identifier(
          identifier: params[:identifier],
          type: params[:type]
        )

        return render_user_not_found('Usuário não encontrado com o identificador fornecido') unless user
        return render_unauthorized_access unless authorized_to_view?(user)

        render_user_with_data(user)
      rescue StandardError => e
        render_user_error(e)
      end

      # GET /api/v1/user_by_profile/:profile_id
      # Specific endpoint to get user information by UserProfile ID
      def user_by_profile
        profile = UserProfile.find_by(id: params[:profile_id])
        user = profile&.user

        return render_profile_not_found unless user
        return render_unauthorized_access unless authorized_to_view?(user)

        render_user_with_data(user)
      rescue StandardError => e
        render_user_error(e)
      end

      # GET /api/v1/user_by_id/:user_id
      # Specific endpoint to get user information by User ID
      def user_by_id
        user = User.find_by(id: params[:user_id])

        return render_user_not_found('Usuário não encontrado com o ID fornecido') unless user
        return render_unauthorized_access unless authorized_to_view?(user)

        render_user_with_data(user)
      rescue StandardError => e
        render_user_error(e)
      end

      private

      def authorized_to_view?(user)
        CurrentUser::AuthorizationService.can_view_user?(
          user: user,
          current_user: @current_user
        )
      end

      def render_user_with_data(user)
        user = CurrentUser::UserFinderService.load_with_associations(user.id)
        serialized_data = FullUserSerializer.new(user).serializable_hash
        render_user_success(data: serialized_data[:data])
      end
    end
  end
end
