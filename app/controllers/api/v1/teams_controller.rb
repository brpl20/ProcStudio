# frozen_string_literal: true

module Api
  module V1
    class TeamsController < BackofficeController
      before_action :authorize_super_admin!, except: [:show, :update]
      before_action :set_team, only: [:show, :update, :destroy]
      before_action :check_team_access!, only: [:show, :update]

      # GET /api/v1/teams
      def index
        teams = Team.all
        render json: { teams: teams.as_json(only: [:id, :name, :subdomain, :created_at]) }
      end

      # GET /api/v1/teams/1
      def show
        render json: { team: @team.as_json(only: [:id, :name, :subdomain, :settings, :created_at]) }
      end

      # POST /api/v1/teams
      def create
        team = Team.new(team_params)

        if team.save
          render json: {
            team: team.as_json(only: [:id, :name, :subdomain, :created_at]),
            message: 'Team criado com sucesso!'
          }, status: :created
        else
          render json: {
            errors: team.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/teams/1
      # Super admins podem atualizar qualquer team
      # Admins com role lawyer podem atualizar apenas o próprio team
      def update
        if @team.update(team_params)
          render json: {
            team: @team.as_json(only: [:id, :name, :subdomain, :settings, :created_at]),
            message: 'Team atualizado com sucesso!'
          }
        else
          render json: {
            errors: @team.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/teams/1
      def destroy
        @team.destroy
        render json: { message: 'Team excluído com sucesso!' }
      end

      private

      def set_team
        @team = Team.find(params[:id])
      end

      def team_params
        # Não permitir alteração de subdomain por questões de segurança
        params.require(:team).permit(:name, settings: {})
      end

      def authorize_super_admin!
        return if @current_admin&.profile_admin&.super_admin?

        action_map = {
          'index' => 'index?',
          'create' => 'create?',
          'update' => 'update?',
          'destroy' => 'destroy?'
        }
        error_key = action_map[action_name] || 'default'
        render json: { error: I18n.t("pundit.team.#{error_key}") }, status: :forbidden
      end

      def check_team_access!
        # Admins com role super_admin podem acessar qualquer team
        return if @current_admin&.profile_admin&.super_admin?

        # Para update, verificar se é o próprio team e se tem role lawyer
        if action_name == 'update'
          # Permitir update apenas se for o próprio team e tiver role lawyer
          if @team != @current_admin.team
            render json: { error: 'Não autorizado a atualizar este team. Você só pode atualizar o seu próprio team.' },
                   status: :forbidden
            nil
          elsif !@current_admin.profile_admin&.lawyer?
            render json: { error: 'Não autorizado a atualizar teams. Apenas administradores com role lawyer ou super_admin podem executar esta ação.' },
                   status: :forbidden
            nil
          end
        else
          # Para show, qualquer admin pode ver o próprio team
          unless @team == @current_admin.team
            render json: { error: I18n.t('pundit.team.show?') }, status: :forbidden
            nil
          end
        end
      end
    end
  end
end
