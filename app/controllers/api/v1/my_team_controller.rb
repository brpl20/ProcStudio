# frozen_string_literal: true

module Api
  module V1
    class MyTeamController < BackofficeController
      def show
        team = @current_admin.team

        render json: {
          team: {
            id: team.id,
            name: team.name,
            subdomain: team.subdomain,
            settings: team.settings,
            created_at: team.created_at,
            stats: {
              admins_count: team.admins.count,
              customers_count: team.customers.count,
              works_count: team.works.count,
              jobs_count: team.jobs.count,
              offices_count: team.offices.count
            }
          },
          current_admin: {
            id: @current_admin.id,
            email: @current_admin.email,
            role: @current_admin.profile_admin&.role,
            name: @current_admin.profile_admin&.name,
            last_name: @current_admin.profile_admin&.last_name
          }
        }
      end

      def update
        team = @current_admin.team

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
        admins = @current_admin.team.admins.includes(:profile_admin)

        render json: {
          members: admins.map do |admin|
            {
              id: admin.id,
              email: admin.email,
              status: admin.status,
              profile: if admin.profile_admin
                         {
                           name: admin.profile_admin.name,
                           last_name: admin.profile_admin.last_name,
                           role: admin.profile_admin.role,
                           oab: admin.profile_admin.oab
                         }
                       end,
              joined_at: admin.created_at
            }
          end,
          total_count: admins.count
        }
      end

      private

      def team_params
        params.require(:team).permit(:name, settings: {})
        # Não permitir alterar subdomain por questões de segurança
      end
    end
  end
end
