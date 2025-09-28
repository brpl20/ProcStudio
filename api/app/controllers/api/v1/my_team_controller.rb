# frozen_string_literal: true

module Api
  module V1
    class MyTeamController < BackofficeController
      def show
        team = @current_user.team
        render_team_data(team)
      rescue StandardError => e
        render_error_response(e)
      end

      def update
        team = @current_user.team

        if team.update(team_params)
          render_team_update_success(team)
        else
          render_team_update_error(team)
        end
      rescue StandardError => e
        render_error_response(e)
      end

      def members
        users = @current_user.team.users.includes(:user_profile)
        render_members_data(users)
      rescue StandardError => e
        render_error_response(e)
      end

      private

      def team_params
        params.expect(team: [:name, { settings: {} }])
        # Não permitir alterar subdomain por questões de segurança
      end

      def render_team_data(team)
        render json: {
          success: true,
          message: 'Dados do team obtidos com sucesso',
          data: {
            team: team_data(team),
            current_user: current_user_data
          }
        }, status: :ok
      end

      def team_data(team)
        {
          id: team.id,
          name: team.name,
          subdomain: team.subdomain,
          settings: team.settings,
          created_at: team.created_at,
          stats: team_stats(team)
        }
      end

      def team_stats(team)
        {
          users_count: team.users.count,
          customers_count: team.customers.count,
          works_count: team.works.count,
          jobs_count: team.jobs.count,
          offices_count: team.offices.count
        }
      end

      def current_user_data
        {
          id: @current_user.id,
          email: @current_user.email,
          role: @current_user.user_profile&.role,
          name: @current_user.user_profile&.name,
          last_name: @current_user.user_profile&.last_name
        }
      end

      def render_team_update_success(team)
        render json: {
          success: true,
          message: 'Team atualizado com sucesso',
          data: {
            team: {
              id: team.id,
              name: team.name,
              subdomain: team.subdomain,
              settings: team.settings
            }
          }
        }, status: :ok
      end

      def render_team_update_error(team)
        error_messages = team.errors.full_messages
        render json: {
          success: false,
          message: error_messages.first,
          errors: error_messages
        }, status: :unprocessable_content
      end

      def render_members_data(users)
        render json: {
          success: true,
          message: 'Membros do team obtidos com sucesso',
          data: {
            members: users.map { |user| member_data(user) },
            total_count: users.count
          }
        }, status: :ok
      end

      def member_data(user)
        {
          id: user.id,
          email: user.email,
          status: user.status,
          profile: user_profile_data(user.user_profile),
          joined_at: user.created_at
        }
      end

      def user_profile_data(profile)
        return nil unless profile

        {
          name: profile.name,
          last_name: profile.last_name,
          role: profile.role,
          oab: profile.oab
        }
      end

      def render_error_response(error)
        render json: {
          success: false,
          message: error.message,
          errors: [error.message]
        }, status: :internal_server_error
      end
    end
  end
end
