# frozen_string_literal: true

module Api
  module V1
    class CurrentUserController < BackofficeController
      # No authorization check needed for these endpoints
      # Users can always see their own data, and we handle team member access manually

      # GET /api/v1/whoami
      # Returns the complete information of the currently authenticated user
      def whoami
        # Eager load all associations to avoid N+1 queries
        user = User.includes(
          :team,
          :offices,
          :user_offices,
          user_profile: [:office, :phones, :addresses, :bank_accounts, :works, :jobs]
        ).find(@current_user.id)

        serialized_data = FullUserSerializer.new(user).serializable_hash

        render json: {
          success: true,
          message: 'Informações do usuário atual obtidas com sucesso',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/user_info/:identifier
      # Returns complete user information by User ID or UserProfile ID
      # @param identifier can be either a User ID or UserProfile ID
      # @param type (optional) specifies if identifier is 'user_id' or 'profile_id'
      def user_info
        user = find_user_by_identifier

        unless user
          return render json: {
            success: false,
            message: 'Usuário não encontrado',
            errors: ['Usuário não encontrado com o identificador fornecido']
          }, status: :not_found
        end

        # Check authorization - users can only see their own info or team members if admin
        unless can_view_user?(user)
          return render json: {
            success: false,
            message: 'Acesso não autorizado',
            errors: ['Você não tem permissão para visualizar as informações deste usuário']
          }, status: :forbidden
        end

        # Reload with eager loading
        user = load_user_with_associations(user.id)
        serialized_data = FullUserSerializer.new(user).serializable_hash

        render json: {
          success: true,
          message: 'Informações do usuário obtidas com sucesso',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/user_by_profile/:profile_id
      # Specific endpoint to get user information by UserProfile ID
      def user_by_profile
        profile = UserProfile.find_by(id: params[:profile_id])

        unless profile
          return render json: {
            success: false,
            message: 'Perfil não encontrado',
            errors: ['Perfil não encontrado com o ID fornecido']
          }, status: :not_found
        end

        user = profile.user

        # Check authorization
        unless can_view_user?(user)
          return render json: {
            success: false,
            message: 'Acesso não autorizado',
            errors: ['Você não tem permissão para visualizar as informações deste usuário']
          }, status: :forbidden
        end

        # Reload with eager loading
        user = load_user_with_associations(user.id)
        serialized_data = FullUserSerializer.new(user).serializable_hash

        render json: {
          success: true,
          message: 'Informações do usuário obtidas com sucesso',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/user_by_id/:user_id
      # Specific endpoint to get user information by User ID
      def user_by_id
        user = User.find_by(id: params[:user_id])

        unless user
          return render json: {
            success: false,
            message: 'Usuário não encontrado',
            errors: ['Usuário não encontrado com o ID fornecido']
          }, status: :not_found
        end

        # Check authorization
        unless can_view_user?(user)
          return render json: {
            success: false,
            message: 'Acesso não autorizado',
            errors: ['Você não tem permissão para visualizar as informações deste usuário']
          }, status: :forbidden
        end

        # Reload with eager loading
        user = load_user_with_associations(user.id)
        serialized_data = FullUserSerializer.new(user).serializable_hash

        render json: {
          success: true,
          message: 'Informações do usuário obtidas com sucesso',
          data: serialized_data[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def find_user_by_identifier
        identifier = params[:identifier]
        type = params[:type]

        # If type is specified, use it to determine search method
        case type
        when 'profile_id'
          profile = UserProfile.find_by(id: identifier)
          profile&.user
        when 'user_id'
          User.find_by(id: identifier)
        else
          # Try to auto-detect: first try as User ID, then as UserProfile ID
          user = User.find_by(id: identifier)
          if user.nil?
            profile = UserProfile.find_by(id: identifier)
            profile&.user
          else
            user
          end
        end
      end

      def can_view_user?(user)
        # Users can always view their own information
        return true if user.id == @current_user.id

        # Check if users are in the same team
        user.team_id == @current_user.team_id
      end

      def load_user_with_associations(user_id)
        User.includes(
          :team,
          :offices,
          :user_offices,
          user_profile: [:office, :phones, :addresses, :bank_accounts, :works, :jobs]
        ).find(user_id)
      end
    end
  end
end
