# frozen_string_literal: true

module Api
  module V1
    class InvitationsController < BackofficeController
      skip_before_action :authenticate_user!, only: [:verify, :accept]

      # POST /api/v1/invitations
      # Create and send invitations
      def create
        result = Users::Invitations::CreationService.create_invitations(
          emails: invitation_params[:emails],
          current_user: @current_user,
          base_url: invitation_params[:base_url] || default_base_url
        )

        if result.success?
          render json: {
            success: true,
            data: result.data,
            message: build_success_message(result.data[:summary])
          }, status: :created
        else
          render json: {
            success: false,
            errors: result.errors
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/invitations/:token/verify
      # Verify if invitation token is valid
      def verify
        result = Users::Invitations::VerificationService.verify_invitation(
          token: params[:token]
        )

        if result.success?
          render json: {
            success: true,
            data: result.data
          }, status: :ok
        else
          render json: {
            success: false,
            errors: result.errors
          }, status: :not_found
        end
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # POST /api/v1/invitations/:token/accept
      # Accept invitation and create user account
      def accept
        result = Users::Invitations::AcceptanceService.accept_invitation(
          token: params[:token],
          user_params: acceptance_params
        )

        if result.success?
          render json: {
            success: true,
            data: result.data,
            message: result.data[:message]
          }, status: :created
        else
          render json: {
            success: false,
            errors: result.errors
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/invitations
      # List invitations sent by current user
      def index
        invitations = @current_user.team.user_invitations
                                    .includes(:invited_by, :team)
                                    .order(created_at: :desc)

        invitations = filter_by_status(invitations) if params[:status].present?

        render json: {
          success: true,
          data: invitations.map { |inv| serialize_invitation(inv) }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # DELETE /api/v1/invitations/:id
      # Cancel/delete an invitation
      def destroy
        invitation = @current_user.team.user_invitations.find(params[:id])

        if invitation.pending?
          invitation.destroy
          render json: {
            success: true,
            message: 'Convite cancelado com sucesso'
          }, status: :ok
        else
          render json: {
            success: false,
            errors: ['Apenas convites pendentes podem ser cancelados']
          }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          errors: ['Convite não encontrado']
        }, status: :not_found
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def invitation_params
        params.permit(:base_url, emails: [])
      end

      def acceptance_params
        params.permit(
          :password,
          :password_confirmation,
          user_profile_attributes: [
            :name,
            :last_name,
            :cpf,
            :oab,
            :gender,
            :birth,
            :civil_status,
            :nationality,
            :mother_name,
            :rg,
            :office_id
          ]
        )
      end

      def default_base_url
        # This should be configured based on environment
        Rails.env.production? ? 'https://app.procstudio.com' : 'http://localhost:5173'
      end

      def build_success_message(summary)
        if summary[:failed_count].zero?
          "#{summary[:successful_count]} convite(s) enviado(s) com sucesso"
        else
          "#{summary[:successful_count]} convite(s) enviado(s), #{summary[:failed_count]} falhou(ram)"
        end
      end

      def filter_by_status(invitations)
        case params[:status]
        when 'pending'
          invitations.pending.not_expired
        when 'accepted'
          invitations.accepted
        when 'expired'
          invitations.expired
        else
          invitations
        end
      end

      def serialize_invitation(invitation)
        {
          id: invitation.id,
          email: invitation.email,
          status: invitation.status,
          invited_by: {
            id: invitation.invited_by.id,
            name: invitation.invited_by.user_profile&.full_name
          },
          team_name: invitation.team.name,
          expires_at: invitation.expires_at,
          days_until_expiration: invitation.days_until_expiration,
          accepted_at: invitation.accepted_at,
          created_at: invitation.created_at
        }
      end
    end
  end
end
