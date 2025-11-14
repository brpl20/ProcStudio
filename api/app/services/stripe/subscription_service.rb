# frozen_string_literal: true

module Stripe
  class SubscriptionService
    def self.create_checkout_session(team:, extra_users: 0, success_url:, cancel_url:)
      new(team: team, extra_users: extra_users, success_url: success_url, cancel_url: cancel_url).create_checkout_session
    end

    def initialize(team:, extra_users:, success_url:, cancel_url:)
      @team = team
      @extra_users = extra_users.to_i
      @success_url = success_url
      @cancel_url = cancel_url
    end

    def create_checkout_session
      customer = Stripe::CustomerService.find_or_create_for_team(team: team)

      session = ::Stripe::Checkout::Session.create(
        customer: customer.id,
        mode: 'subscription',
        line_items: build_line_items,
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: {
          team_id: team.id,
          extra_users: extra_users
        }
      )

      session
    rescue ::Stripe::StripeError => e
      Rails.logger.error("[Stripe Checkout] Error: #{e.message}")
      raise
    end

    private

    attr_reader :team, :extra_users, :success_url, :cancel_url

    def build_line_items
      items = [
        {
          price: Rails.configuration.stripe[:price_pro_monthly],
          quantity: 1
        }
      ]

      if extra_users.positive?
        items << {
          price: Rails.configuration.stripe[:price_extra_user],
          quantity: extra_users
        }
      end

      items
    end
  end
end
