# frozen_string_literal: true

module Subscriptions
  class UpgradeService
    def self.upgrade_to_pro(team:, stripe_subscription_id: nil, extra_users: 0)
      new(team: team, stripe_subscription_id: stripe_subscription_id, extra_users: extra_users).call
    end

    def initialize(team:, stripe_subscription_id:, extra_users:)
      @team = team
      @stripe_subscription_id = stripe_subscription_id
      @extra_users = extra_users.to_i
    end

    def call
      validate_upgrade
      return build_error_result(validation_errors) if validation_errors.any?

      perform_upgrade
    end

    private

    attr_reader :team, :stripe_subscription_id, :extra_users, :validation_errors

    def validate_upgrade
      @validation_errors = []

      subscription = team.subscription
      if subscription&.pro?
        @validation_errors << 'Time já está no plano Pro'
      end

      if extra_users.negative?
        @validation_errors << 'Número de usuários extras inválido'
      end
    end

    def perform_upgrade
      ActiveRecord::Base.transaction do
        subscription = team.subscription || team.create_subscription!(plan_type: :basic)

        subscription.update!(
          plan_type: :pro,
          stripe_subscription_id: stripe_subscription_id,
          extra_users_count: extra_users,
          current_period_start: Time.current,
          current_period_end: 1.month.from_now
        )

        # Check if this is from a referral and mark as converted
        check_and_convert_referral

        build_success_result(subscription)
      end
    rescue StandardError => e
      Rails.logger.error("[Upgrade Error]: #{e.message}")
      build_error_result([e.message])
    end

    def check_and_convert_referral
      # Find the user who created this team (first user)
      team_owner = team.users.order(:created_at).first
      return unless team_owner

      # Check if they came from a referral
      referral = team_owner.received_referral
      return unless referral&.accepted?

      # Mark referral as converted and award free month
      referral.mark_as_converted!
      Rails.logger.info("[Referral Conversion] Team #{team.id} upgraded to Pro via referral #{referral.id}")
    end

    def build_success_result(subscription)
      Result.new(
        success: true,
        data: {
          subscription: {
            id: subscription.id,
            plan_type: subscription.plan_type,
            status: subscription.status,
            monthly_cost: subscription.monthly_cost,
            extra_users_count: subscription.extra_users_count
          },
          message: 'Plano atualizado para Pro com sucesso!'
        }
      )
    end

    def build_error_result(errors)
      Result.new(
        success: false,
        errors: Array(errors)
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
