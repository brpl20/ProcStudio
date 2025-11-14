# frozen_string_literal: true

module Users
  module Invitations
    class AcceptanceService
      def self.accept_invitation(token:, user_params:)
        new(token: token, user_params: user_params).call
      end

      def initialize(token:, user_params:)
        @token = token
        @user_params = user_params
      end

      def call
        find_invitation
        return build_error_result('Convite não encontrado') unless invitation

        validate_invitation
        return build_error_result(validation_errors.join(', ')) if validation_errors.any?

        create_user_from_invitation
      end

      private

      attr_reader :token, :user_params, :invitation, :validation_errors

      def find_invitation
        @invitation = UserInvitation.find_by(token: token)
      end

      def validate_invitation
        @validation_errors = []

        unless invitation.valid_for_acceptance?
          if invitation.expired?
            @validation_errors << 'Este convite expirou'
          elsif invitation.accepted?
            @validation_errors << 'Este convite já foi aceito'
          else
            @validation_errors << 'Este convite não é mais válido'
          end
        end

        if User.exists?(email: invitation.email)
          @validation_errors << 'Este e-mail já está cadastrado'
        end
      end

      def create_user_from_invitation
        ActiveRecord::Base.transaction do
          user = create_user
          return build_error_result(user.errors.full_messages) unless user.persisted?

          invitation.mark_as_accepted!

          build_success_result(user)
        end
      rescue StandardError => e
        Rails.logger.error("[Invitation Acceptance Error]: #{e.message}")
        build_error_result("Erro ao criar usuário: #{e.message}")
      end

      def create_user
        User.create(
          email: invitation.email,
          password: user_params[:password],
          password_confirmation: user_params[:password_confirmation],
          team: invitation.team,
          user_profile_attributes: build_user_profile_attributes
        )
      end

      def build_user_profile_attributes
        profile_attrs = user_params[:user_profile_attributes] || {}

        {
          name: profile_attrs[:name],
          last_name: profile_attrs[:last_name],
          role: invitation.metadata['suggested_role'] || 'lawyer',
          cpf: profile_attrs[:cpf],
          oab: profile_attrs[:oab],
          gender: profile_attrs[:gender],
          birth: profile_attrs[:birth],
          civil_status: profile_attrs[:civil_status],
          nationality: profile_attrs[:nationality],
          mother_name: profile_attrs[:mother_name],
          rg: profile_attrs[:rg],
          office_id: profile_attrs[:office_id]
        }.compact
      end

      def build_success_result(user)
        Result.new(
          success: true,
          data: {
            user: serialize_user(user),
            invitation: serialize_invitation,
            message: 'Conta criada com sucesso! Bem-vindo ao Procstudio.'
          }
        )
      end

      def build_error_result(errors)
        Result.new(
          success: false,
          errors: Array(errors)
        )
      end

      def serialize_user(user)
        {
          id: user.id,
          email: user.email,
          team_id: user.team_id,
          team_name: user.team.name,
          profile: {
            id: user.user_profile&.id,
            name: user.user_profile&.name,
            last_name: user.user_profile&.last_name,
            full_name: user.user_profile&.full_name,
            role: user.user_profile&.role
          }
        }
      end

      def serialize_invitation
        {
          id: invitation.id,
          invited_by: {
            id: invitation.invited_by.id,
            name: invitation.invited_by.user_profile&.full_name
          },
          accepted_at: invitation.accepted_at
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
