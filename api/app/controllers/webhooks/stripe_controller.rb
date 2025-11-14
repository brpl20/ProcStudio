# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = Rails.configuration.stripe[:webhook_secret]

      begin
        event = ::Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      rescue JSON::ParserError => e
        Rails.logger.error("[Stripe Webhook] Invalid payload: #{e.message}")
        return head :bad_request
      rescue ::Stripe::SignatureVerificationError => e
        Rails.logger.error("[Stripe Webhook] Invalid signature: #{e.message}")
        return head :bad_request
      end

      handle_event(event)

      head :ok
    end

    private

    def handle_event(event)
      case event.type
      when 'checkout.session.completed'
        handle_checkout_completed(event.data.object)
      when 'customer.subscription.updated'
        handle_subscription_updated(event.data.object)
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event.data.object)
      when 'invoice.payment_succeeded'
        handle_payment_succeeded(event.data.object)
      when 'invoice.payment_failed'
        handle_payment_failed(event.data.object)
      else
        Rails.logger.info("[Stripe Webhook] Unhandled event type: #{event.type}")
      end
    rescue StandardError => e
      Rails.logger.error("[Stripe Webhook] Error handling #{event.type}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end

    def handle_checkout_completed(session)
      team_id = session.metadata.team_id
      team = Team.find_by(id: team_id)

      unless team
        Rails.logger.error("[Stripe Webhook] Team #{team_id} not found")
        return
      end

      # Retrieve the subscription from Stripe
      stripe_subscription = ::Stripe::Subscription.retrieve(session.subscription)

      # Upgrade team to Pro
      Subscriptions::UpgradeService.upgrade_to_pro(
        team: team,
        stripe_subscription_id: stripe_subscription.id,
        extra_users: session.metadata.extra_users.to_i
      )

      Rails.logger.info("[Stripe Webhook] Checkout completed for team #{team_id}")
    end

    def handle_subscription_updated(subscription)
      team_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)

      unless team_subscription
        Rails.logger.warn("[Stripe Webhook] Subscription #{subscription.id} not found in database")
        return
      end

      team_subscription.update!(
        status: subscription.status,
        current_period_start: Time.at(subscription.current_period_start),
        current_period_end: Time.at(subscription.current_period_end)
      )

      # Check for free months and apply if needed
      if team_subscription.has_free_months?
        team_subscription.use_free_month!
        Rails.logger.info("[Stripe Webhook] Used 1 free month for team #{team_subscription.team_id}")
      end

      Rails.logger.info("[Stripe Webhook] Subscription updated: #{subscription.id}")
    end

    def handle_subscription_deleted(subscription)
      team_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)

      unless team_subscription
        Rails.logger.warn("[Stripe Webhook] Subscription #{subscription.id} not found in database")
        return
      end

      team_subscription.cancel!
      Rails.logger.info("[Stripe Webhook] Subscription deleted: #{subscription.id}")
    end

    def handle_payment_succeeded(invoice)
      Rails.logger.info("[Stripe Webhook] Payment succeeded: #{invoice.id}")
      # TODO: Send success email, update payment history, etc.
    end

    def handle_payment_failed(invoice)
      Rails.logger.warn("[Stripe Webhook] Payment failed: #{invoice.id}")
      # TODO: Send failure email, notify team, etc.
    end
  end
end
