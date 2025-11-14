# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < BackofficeController
      def show
        subscription = @current_user.team.subscription || create_default_subscription
        usage = @current_user.team.usage_limit

        render json: {
          success: true,
          subscription: serialize_subscription(subscription),
          usage: usage&.usage_summary
        }, status: :ok
      end

      def create_checkout_session
        result = Stripe::SubscriptionService.create_checkout_session(
          team: @current_user.team,
          extra_users: params[:extra_users] || 0,
          success_url: params[:success_url] || default_success_url,
          cancel_url: params[:cancel_url] || default_cancel_url
        )

        render json: {
          success: true,
          checkout_url: result.url,
          session_id: result.id
        }, status: :ok
      rescue Stripe::StripeError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :unprocessable_entity
      end

      def cancel
        subscription = @current_user.team.subscription

        unless subscription&.pro?
          return render json: {
            success: false,
            errors: ['Apenas assinaturas Pro podem ser canceladas']
          }, status: :unprocessable_entity
        end

        subscription.cancel!

        # Cancel in Stripe if exists
        if subscription.stripe_subscription_id.present?
          begin
            ::Stripe::Subscription.cancel(subscription.stripe_subscription_id)
          rescue ::Stripe::StripeError => e
            Rails.logger.error("[Stripe Cancel] Error: #{e.message}")
          end
        end

        render json: {
          success: true,
          message: 'Assinatura cancelada com sucesso'
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          errors: [e.message]
        }, status: :internal_server_error
      end

      private

      def create_default_subscription
        Subscriptions::CreationService.create_for_team(
          team: @current_user.team,
          plan_type: 'basic'
        )
      end

      def serialize_subscription(subscription)
        {
          id: subscription.id,
          plan_type: subscription.plan_type,
          status: subscription.status,
          monthly_cost: subscription.monthly_cost,
          extra_users_count: subscription.extra_users_count,
          free_months_remaining: subscription.free_months_remaining,
          current_period_start: subscription.current_period_start,
          current_period_end: subscription.current_period_end,
          canceled_at: subscription.canceled_at
        }
      end

      def default_success_url
        "#{request.base_url}/subscription/success"
      end

      def default_cancel_url
        "#{request.base_url}/subscription/cancel"
      end
    end
  end
end
