# frozen_string_literal: true

module Subscriptions
  class CreationService
    def self.create_for_team(team:, plan_type: 'basic')
      new(team: team, plan_type: plan_type).call
    end

    def initialize(team:, plan_type:)
      @team = team
      @plan_type = plan_type
    end

    def call
      return team.subscription if team.subscription.present?

      create_subscription
    end

    private

    attr_reader :team, :plan_type

    def create_subscription
      ActiveRecord::Base.transaction do
        subscription = Subscription.create!(
          team: team,
          plan_type: plan_type,
          status: :active
        )

        # Initialize usage limits
        team.create_usage_limit! unless team.usage_limit

        subscription
      end
    rescue StandardError => e
      Rails.logger.error("[Subscription Creation Error]: #{e.message}")
      nil
    end
  end
end
