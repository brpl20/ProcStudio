# frozen_string_literal: true

module Stripe
  class CustomerService
    def self.find_or_create_for_team(team:)
      new(team: team).find_or_create
    end

    def initialize(team:)
      @team = team
    end

    def find_or_create
      subscription = team.subscription

      if subscription&.stripe_customer_id.present?
        find_customer(subscription.stripe_customer_id)
      else
        create_customer
      end
    end

    private

    attr_reader :team

    def find_customer(customer_id)
      ::Stripe::Customer.retrieve(customer_id)
    rescue ::Stripe::InvalidRequestError => e
      Rails.logger.error("[Stripe Customer] Customer #{customer_id} not found: #{e.message}")
      create_customer
    end

    def create_customer
      team_owner = team.users.order(:created_at).first
      email = team_owner&.email || "team#{team.id}@procstudio.com"

      customer = ::Stripe::Customer.create(
        email: email,
        name: team.name,
        metadata: {
          team_id: team.id,
          team_name: team.name,
          subdomain: team.subdomain
        }
      )

      # Update subscription with customer ID
      team.subscription&.update(stripe_customer_id: customer.id)

      customer
    rescue ::Stripe::StripeError => e
      Rails.logger.error("[Stripe Customer] Error creating customer: #{e.message}")
      raise
    end
  end
end
