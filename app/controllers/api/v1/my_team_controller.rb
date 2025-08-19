# frozen_string_literal: true

module Api
  module V1
    class MyTeamController < BackofficeController
      def show
        team = @current_user.team

        render json: {
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
      end

      def update
        team = @current_user.team

        if team.update(team_params)
          render json: {
            success: true,
            message: 'Team atualizado com sucesso!',
            team: {
              id: team.id,
              name: team.name,
              subdomain: team.subdomain,
              settings: team.settings
            }
          }
        else
          render json: {
            success: false,
            errors: team.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def members
        users = @current_user.team.users.includes(:user_profile)

        render json: {
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
      end

      private

      def team_params
        params.expect(team: [:name, { settings: {} }])
        # Não permitir alterar subdomain por questões de segurança
      end
    end
  end
end
