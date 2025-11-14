# frozen_string_literal: true

module Referrals
  class AcceptanceService
    def self.accept_referral(token:, user_params:, team_params:)
      new(token: token, user_params: user_params, team_params: team_params).call
    end

    def initialize(token:, user_params:, team_params:)
      @token = token
      @user_params = user_params
      @team_params = team_params
    end

    def call
      find_referral
      return build_error_result('Indicação não encontrada') unless referral

      validate_referral
      return build_error_result(validation_errors.join(', ')) if validation_errors.any?

      create_team_and_user_from_referral
    end

    private

    attr_reader :token, :user_params, :team_params, :referral, :validation_errors

    def find_referral
      @referral = ReferralInvitation.find_by(token: token)
    end

    def validate_referral
      @validation_errors = []

      unless referral.valid_for_acceptance?
        if referral.expired?
          @validation_errors << 'Esta indicação expirou'
        elsif referral.accepted?
          @validation_errors << 'Esta indicação já foi aceita'
        else
          @validation_errors << 'Esta indicação não é mais válida'
        end
      end

      if User.exists?(email: referral.email)
        @validation_errors << 'Este e-mail já está cadastrado'
      end
    end

    def create_team_and_user_from_referral
      ActiveRecord::Base.transaction do
        team = create_team
        return build_error_result(team.errors.full_messages) unless team.persisted?

        user = create_user(team)
        return build_error_result(user.errors.full_messages) unless user.persisted?

        # Create Basic subscription by default
        subscription = create_subscription(team)
        return build_error_result('Erro ao criar assinatura') unless subscription

        referral.mark_as_accepted!(user)

        build_success_result(user, team)
      end
    rescue StandardError => e
      Rails.logger.error("[Referral Acceptance Error]: #{e.message}")
      build_error_result("Erro ao criar conta: #{e.message}")
    end

    def create_team
      Team.create(
        name: team_params[:name] || "Time #{referral.email.split('@').first}",
        subdomain: generate_unique_subdomain
      )
    end

    def create_user(team)
      User.create(
        email: referral.email,
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation],
        team: team,
        user_profile_attributes: build_user_profile_attributes
      )
    end

    def create_subscription(team)
      Subscriptions::CreationService.create_for_team(team: team, plan_type: 'basic')
    end

    def generate_unique_subdomain
      base = (team_params[:subdomain] || referral.email.split('@').first).parameterize
      subdomain = base

      counter = 1
      while Team.exists?(subdomain: subdomain)
        subdomain = "#{base}-#{counter}"
        counter += 1
      end

      subdomain
    end

    def build_user_profile_attributes
      profile_attrs = user_params[:user_profile_attributes] || {}

      {
        name: profile_attrs[:name],
        last_name: profile_attrs[:last_name],
        role: 'lawyer',
        cpf: profile_attrs[:cpf],
        oab: profile_attrs[:oab],
        gender: profile_attrs[:gender],
        birth: profile_attrs[:birth],
        civil_status: profile_attrs[:civil_status],
        nationality: profile_attrs[:nationality],
        mother_name: profile_attrs[:mother_name],
        rg: profile_attrs[:rg]
      }.compact
    end

    def build_success_result(user, team)
      Result.new(
        success: true,
        data: {
          user: serialize_user(user),
          team: serialize_team(team),
          referral: serialize_referral,
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
        profile: {
          id: user.user_profile&.id,
          name: user.user_profile&.name,
          full_name: user.user_profile&.full_name,
          role: user.user_profile&.role
        }
      }
    end

    def serialize_team(team)
      {
        id: team.id,
        name: team.name,
        subdomain: team.subdomain
      }
    end

    def serialize_referral
      {
        id: referral.id,
        referred_by: {
          id: referral.referred_by.id,
          name: referral.referred_by.user_profile&.full_name
        },
        accepted_at: referral.accepted_at
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
