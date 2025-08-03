# frozen_string_literal: true

module Api
  module V1
    class TeamsController < BackofficeController
      before_action :set_team, only: %i[show update destroy add_member remove_member update_member]
      skip_before_action :require_team!, only: %i[index create]

      def index
        @teams = current_admin.teams.includes(:subscriptions, :team_memberships)
        render json: @teams
      end

      def show
        render json: @team
      end

      def create
        @team = Team.new(team_params)
        @team.owner_admin = current_admin
        @team.main_admin = current_admin

        ActiveRecord::Base.transaction do
          if @team.save
            TeamMembership.create!(
              team: @team,
              admin: current_admin,
              role: 'owner',
              status: 'active'
            )
            render json: @team, status: :created
          else
            render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      def update
        authorize_team_management!
        
        if @team.update(team_params)
          render json: @team
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_team_management!
        
        if @team.destroy
          head :no_content
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def add_member
        authorize_team_management!
        
        admin = Admin.find_by(email: member_params[:email])
        
        unless admin
          return render json: { error: 'Admin not found' }, status: :not_found
        end
        
        membership = @team.team_memberships.build(
          admin: admin,
          role: member_params[:role] || 'member',
          status: 'active'
        )
        
        if membership.save
          render json: membership, status: :created
        else
          render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def remove_member
        authorize_team_management!
        
        membership = @team.team_memberships.find_by(admin_id: params[:admin_id])
        
        unless membership
          return render json: { error: 'Member not found' }, status: :not_found
        end
        
        if membership.admin == @team.owner_admin
          return render json: { error: 'Cannot remove team owner' }, status: :unprocessable_entity
        end
        
        if membership.destroy
          head :no_content
        else
          render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update_member
        authorize_team_management!
        
        membership = @team.team_memberships.find_by(admin_id: params[:admin_id])
        
        unless membership
          return render json: { error: 'Member not found' }, status: :not_found
        end
        
        if membership.update(role: member_params[:role])
          render json: membership
        else
          render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_team
        @team = current_admin.teams.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Team not found' }, status: :not_found
      end

      def team_params
        params.require(:team).permit(:name, :subdomain, :email_domain, :description)
      end

      def member_params
        params.require(:member).permit(:email, :role)
      end

      def authorize_team_management!
        unless current_admin.team_role(@team).in?(%w[owner admin])
          render json: { error: 'Not authorized to manage this team' }, status: :forbidden
        end
      end
    end
  end
end