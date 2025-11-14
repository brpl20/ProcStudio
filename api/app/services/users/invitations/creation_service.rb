# frozen_string_literal: true

module Users
  module Invitations
    class CreationService
      MAX_INVITATIONS_PER_REQUEST = 50

      def self.create_invitations(emails:, current_user:, base_url:)
        new(emails: emails, current_user: current_user, base_url: base_url).call
      end

      def initialize(emails:, current_user:, base_url:)
        @emails = normalize_emails(emails)
        @current_user = current_user
        @base_url = base_url
        @successful_invitations = []
        @failed_invitations = []
      end

      def call
        validate_inputs
        return build_error_result if @errors.present?

        process_invitations

        build_result
      end

      private

      attr_reader :emails, :current_user, :base_url, :successful_invitations, :failed_invitations

      def normalize_emails(emails)
        return [] unless emails.is_a?(Array)

        emails.map { |email| email.to_s.downcase.strip }.uniq.compact_blank
      end

      def validate_inputs
        @errors = []

        if emails.blank?
          @errors << 'Nenhum e-mail fornecido'
          return
        end

        if emails.size > MAX_INVITATIONS_PER_REQUEST
          @errors << "Máximo de #{MAX_INVITATIONS_PER_REQUEST} convites por vez"
        end

        invalid_emails = emails.reject { |email| valid_email?(email) }
        if invalid_emails.any?
          @errors << "E-mails inválidos: #{invalid_emails.join(', ')}"
        end
      end

      def valid_email?(email)
        email.match?(URI::MailTo::EMAIL_REGEXP)
      end

      def process_invitations
        emails.each do |email|
          process_single_invitation(email)
        end
      end

      def process_single_invitation(email)
        invitation = create_invitation(email)

        if invitation.persisted?
          send_invitation_email(invitation)
          successful_invitations << invitation
        else
          failed_invitations << { email: email, errors: invitation.errors.full_messages }
        end
      rescue StandardError => e
        Rails.logger.error("[Invitation Creation Error]: #{e.message}")
        failed_invitations << { email: email, errors: [e.message] }
      end

      def create_invitation(email)
        UserInvitation.create(
          email: email,
          invited_by: current_user,
          team: current_user.team,
          metadata: { suggested_role: 'lawyer' }
        )
      end

      def send_invitation_email(invitation)
        invitation_url = build_invitation_url(invitation)
        Users::Mail::InvitationService.new(invitation, invitation_url).call
      rescue StandardError => e
        Rails.logger.error("[Invitation Email Error]: #{e.message}")
        # Don't fail the invitation if email fails, just log it
      end

      def build_invitation_url(invitation)
        # Make URL configurable for development/production
        # Frontend will handle the route like: /accept-invitation/:token
        "#{base_url}/accept-invitation/#{invitation.token}"
      end

      def build_result
        Result.new(
          success: failed_invitations.empty?,
          data: {
            successful: successful_invitations.map { |inv| serialize_invitation(inv) },
            failed: failed_invitations,
            summary: {
              total: emails.size,
              successful_count: successful_invitations.size,
              failed_count: failed_invitations.size
            }
          }
        )
      end

      def build_error_result
        Result.new(
          success: false,
          errors: @errors
        )
      end

      def serialize_invitation(invitation)
        {
          id: invitation.id,
          email: invitation.email,
          status: invitation.status,
          expires_at: invitation.expires_at,
          days_until_expiration: invitation.days_until_expiration
        }
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
