# frozen_string_literal: true

module Api
  module V1
    class SuperAdminController < ApplicationController
      # Pula o team scoping para acesso total
      before_action :ensure_super_admin_access

      def admins
        admins = Admin.includes(:profile_admin, :team).all

        render json: {
          data: admins.map do |admin|
            {
              id: admin.id,
              email: admin.email,
              oab: admin.oab,
              status: admin.status,
              team: {
                id: admin.team.id,
                name: admin.team.name,
                subdomain: admin.team.subdomain
              },
              profile: if admin.profile_admin
                         {
                           name: admin.profile_admin.name,
                           last_name: admin.profile_admin.last_name,
                           role: admin.profile_admin.role
                         }
                       end
            }
          end,
          meta: {
            total_count: admins.count
          }
        }
      end

      def teams
        teams = Team.includes(:admins).all

        render json: {
          data: teams.map do |team|
            {
              id: team.id,
              name: team.name,
              subdomain: team.subdomain,
              admins_count: team.admins.count,
              created_at: team.created_at
            }
          end,
          meta: {
            total_count: teams.count
          }
        }
      end

      private

      def ensure_super_admin_access
        # Em dev mode, permitir acesso livre
        return if Rails.env.development?

        # Em produção, adicionar lógica de autenticação super admin
        head :forbidden
      end
    end
  end
end
