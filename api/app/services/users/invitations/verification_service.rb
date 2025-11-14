# frozen_string_literal: true

module Users
  module Invitations
    class VerificationService
      def self.verify_invitation(token:)
        new(token: token).call
      end

      def initialize(token:)
        @token = token
      end

      def call
        find_invitation
        return build_error_result('Convite não encontrado') unless invitation

        # Auto-expire if needed
        mark_as_expired_if_needed

        build_result
      end

      private

      attr_reader :token, :invitation

      def find_invitation
        @invitation = UserInvitation.find_by(token: token)
      end

      def mark_as_expired_if_needed
        return unless invitation.pending? && invitation.expired?

        invitation.mark_as_expired!
      end

      def build_result
        if invitation.valid_for_acceptance?
          build_success_result
        else
          build_invalid_result
        end
      end

      def build_success_result
        Result.new(
          success: true,
          data: {
            valid: true,
            invitation: {
              id: invitation.id,
              email: invitation.email,
              team_name: invitation.team.name,
              invited_by: invitation.invited_by.user_profile&.full_name || 'Um colega',
              expires_at: invitation.expires_at,
              days_until_expiration: invitation.days_until_expiration,
              suggested_role: invitation.metadata['suggested_role']
            }
          }
        )
      end

      def build_invalid_result
        reason = if invitation.expired?
                   'Este convite expirou'
                 elsif invitation.accepted?
                   'Este convite já foi aceito'
                 else
                   'Este convite não é válido'
                 end

        Result.new(
          success: true,
          data: {
            valid: false,
            reason: reason,
            status: invitation.status
          }
        )
      end

      def build_error_result(error)
        Result.new(
          success: false,
          errors: [error]
        )
      end

      class Result
        attr_reader :data, :errors

        def initialize(success:, data: nil, errors: nil)
          @success = success
          @data = data
          @errors = errors
        end

        def success?
          @success
        end

        def failure?
          !@success
        end
      end
    end
  end
end
