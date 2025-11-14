# frozen_string_literal: true

module Api
  module V1
    class ReferralsController < BackofficeController
      skip_before_action :authenticate_user, only: [:verify, :accept]
      skip_before_action :set_current_team, only: [:verify, :accept]

      # POST /api/v1/referrals
      def create
        result = Referrals::CreationService.send_referrals(
          emails: referral_params[:emails],
          current_user: @current_user,
          base_url: referral_params[:base_url] || default_base_url
        )

        if result.data.present?
          render json: {
            success: result.success?,
            data: result.data,
            message: build_success_message(result.data[:summary])
          }, status: result.success? ? :created : :ok
        else
          render json: {
            success: false,
            errors: result.errors || ['Erro ao processar indicações']
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/referrals/:token/verify
      def verify
        referral = ReferralInvitation.find_by(token: params[:token])

        unless referral
          return render json: {
            success: false,
            errors: ['Indicação não encontrada']
          }, status: :not_found
        end

        # Auto-expire if needed
        referral.mark_as_expired! if referral.pending? && referral.expired?

        render json: {
          success: true,
          data: {
            valid: referral.valid_for_acceptance?,
            referral: serialize_referral_public(referral)
          }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # POST /api/v1/referrals/:token/accept
      def accept
        result = Referrals::AcceptanceService.accept_referral(
          token: params[:token],
          user_params: acceptance_params,
          team_params: team_params
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

      # GET /api/v1/referrals
      def index
        referrals = @current_user.sent_referrals.order(created_at: :desc)
        referrals = filter_by_status(referrals) if params[:status].present?

        render json: {
          success: true,
          data: referrals.map { |ref| serialize_referral(ref) }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      # GET /api/v1/referrals/stats
      def stats
        referrals = @current_user.sent_referrals

        render json: {
          success: true,
          data: {
            total_sent: referrals.count,
            accepted: referrals.accepted.count + referrals.converted.count,
            converted: referrals.converted.count,
            free_months_earned: referrals.where(reward_earned: true).count,
            pending: referrals.pending.not_expired.count,
            current_free_months: @current_user.team.subscription&.free_months_remaining || 0
          }
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def referral_params
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
            :rg
          ]
        )
      end

      def team_params
        params.permit(:team_name, :subdomain)
      end

      def default_base_url
        Rails.env.production? ? 'https://app.procstudio.com' : 'http://localhost:5173'
      end

      def build_success_message(summary)
        if summary[:failed_count].zero?
          "#{summary[:successful_count]} indicação(ões) enviada(s) com sucesso"
        else
          "#{summary[:successful_count]} indicação(ões) enviada(s), #{summary[:failed_count]} falhou(ram)"
        end
      end

      def filter_by_status(referrals)
        case params[:status]
        when 'pending'
          referrals.pending.not_expired
        when 'accepted'
          referrals.accepted
        when 'converted'
          referrals.converted
        when 'expired'
          referrals.expired
        else
          referrals
        end
      end

      def serialize_referral(referral)
        {
          id: referral.id,
          email: referral.email,
          status: referral.status,
          reward_earned: referral.reward_earned,
          expires_at: referral.expires_at,
          days_until_expiration: referral.days_until_expiration,
          accepted_at: referral.accepted_at,
          converted_at: referral.converted_at,
          created_at: referral.created_at
        }
      end

      def serialize_referral_public(referral)
        {
          email: referral.email,
          status: referral.status,
          referred_by: referral.referred_by.user_profile&.full_name || 'Um amigo',
          expires_at: referral.expires_at,
          days_until_expiration: referral.days_until_expiration
        }
      end
    end
  end
end
