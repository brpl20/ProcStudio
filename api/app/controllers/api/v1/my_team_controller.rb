# frozen_string_literal: true

module Api
  module V1
    class MyTeamController < BackofficeController
      def show
        team = @current_user.team

        render json: {
          success: true,
          message: 'Dados do team obtidos com sucesso',
          data: {
            team: {
              id: team.id,
              name: team.name,
              subdomain: team.subdomain,
              settings: team.settings,
              created_at: team.created_at,
              stats: {
                users_count: team.users.count,
                customers_count: team.customers.count,
                works_count: team.works.count,
                jobs_count: team.jobs.count,
                offices_count: team.offices.count
              }
            },
            current_user: {
              id: @current_user.id,
              email: @current_user.email,
              role: @current_user.user_profile&.role,
              name: @current_user.user_profile&.name,
              last_name: @current_user.user_profile&.last_name
            }
          }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      def update
        team = @current_user.team

        if team.update(team_params)
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

      def members
        users = @current_user.team.users.includes(:user_profile)

        render json: {
          success: true,
          message: 'Membros do team obtidos com sucesso',
          data: {
            members: users.map do |user|
              {
                id: user.id,
                email: user.email,
                status: user.status,
                profile: if user.user_profile
                           {
                             name: user.user_profile.name,
                             last_name: user.user_profile.last_name,
                             role: user.user_profile.role,
                             oab: user.user_profile.oab
                           }
                         end,
                joined_at: user.created_at
              }
            end,
            total_count: users.count
          }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def team_params
        params.expect(team: [:name, { settings: {} }])
        # Não permitir alterar subdomain por questões de segurança
      end
    end
  end
end
