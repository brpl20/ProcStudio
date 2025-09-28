# frozen_string_literal: true

module Api
  module V1
    class TeamsController < BackofficeController
      before_action :authorize_admin!, except: [:show, :update]
      before_action :set_team, only: [:show, :update, :destroy]
      before_action :check_team_access!, only: [:show, :update]

      # GET /api/v1/teams
      def index
        # Only return the current user's team(s)
        teams = Team.where(id: @current_user.team_id)
        render json: {
          success: true,
          message: 'Teams obtidos com sucesso',
          data: teams.as_json(only: [:id, :name, :subdomain, :created_at])
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/teams/1
      def show
        render json: {
          success: true,
          message: 'Team obtido com sucesso',
          data: @team.as_json(only: [:id, :name, :subdomain, :settings, :created_at])
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # POST /api/v1/teams
      def create
        team = Team.new(team_params)

        if team.save
          render json: {
            success: true,
            message: 'Team criado com sucesso',
            data: team.as_json(only: [:id, :name, :subdomain, :created_at])
          }, status: :created
        else
          error_messages = team.errors.full_messages
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

      # PATCH/PUT /api/v1/teams/1
      # Lawyers podem atualizar apenas o próprio team
      def update
        if @team.update(team_params)
          render json: {
            success: true,
            message: 'Team atualizado com sucesso',
            data: @team.as_json(only: [:id, :name, :subdomain, :settings, :created_at])
          }, status: :ok
        else
          error_messages = @team.errors.full_messages
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

      # DELETE /api/v1/teams/1
      def destroy
        @team.destroy
        render json: {
          success: true,
          message: 'Team excluído com sucesso',
          data: { id: @team.id }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :unprocessable_content
      end

      private

      def set_team
        @team = Team.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Team não encontrado',
          errors: ['Team não encontrado']
        }, status: :not_found
      end

      def team_params
        # Não permitir alteração de subdomain por questões de segurança
        params.expect(team: [:name, { settings: {} }])
      end

      def authorize_admin!
        return if @current_user&.user_profile&.lawyer?

        action_map = {
          'index' => 'index?',
          'create' => 'create?',
          'update' => 'update?',
          'destroy' => 'destroy?'
        }
        error_key = action_map[action_name] || 'default'
        error_message = I18n.t("pundit.team.#{error_key}")
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :forbidden
      end

      def check_team_access!
        # Para update, verificar se é o próprio team e se tem role lawyer
        if action_name == 'update'
          # Permitir update apenas se for o próprio team e tiver role lawyer
          if @team != @current_user.team
            error_message = 'Não autorizado a atualizar este team. Você só pode atualizar o seu próprio team.'
            render json: {
              success: false,
              message: error_message,
              errors: [error_message]
            }, status: :forbidden
            nil
          elsif !@current_user.user_profile&.lawyer?
            error_message = 'Não autorizado a atualizar teams. Apenas usuários com role lawyer podem executar esta ação.'
            render json: {
              success: false,
              message: error_message,
              errors: [error_message]
            }, status: :forbidden
            nil
          end
        else
          # Para show, qualquer usuário pode ver o próprio team
          unless @team == @current_user.team
            error_message = I18n.t('pundit.team.show?')
            render json: {
              success: false,
              message: error_message,
              errors: [error_message]
            }, status: :forbidden
            nil
          end
        end
      end
    end
  end
end
