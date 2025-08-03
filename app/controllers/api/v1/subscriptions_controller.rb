# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < BackofficeController
      before_action :set_subscription, only: %i[show update cancel]
      before_action :authorize_subscription_management!

      def show
        render json: @subscription.as_json(
          include: {
            subscription_plan: { only: %i[id name price billing_interval features] },
            payment_transactions: { only: %i[id amount status payment_method processed_at] }
          }
        )
      end

      def create
        @subscription = current_team.build_subscription(subscription_params)
        @subscription.start_date = Date.current
        
        if subscription_params[:subscription_plan_id].present?
          plan = SubscriptionPlan.find(subscription_params[:subscription_plan_id])
          @subscription.subscription_plan = plan
          @subscription.status = plan.price.zero? ? 'active' : 'trial'
        end

        if @subscription.save
          render json: @subscription, status: :created
        else
          render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @subscription.update(subscription_params)
          render json: @subscription
        else
          render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def cancel
        if @subscription.update(status: 'cancelled', end_date: Date.current.end_of_month)
          render json: @subscription
        else
          render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def plans
        plans = SubscriptionPlan.active
        render json: plans
      end

      def usage
        subscription = current_team.subscription
        
        unless subscription
          return render json: { error: 'No active subscription' }, status: :not_found
        end
        
        usage_data = {
          users: {
            used: current_team.admins.count,
            limit: subscription.subscription_plan.max_users,
            percentage: subscription.usage_percentage(:users)
          },
          offices: {
            used: current_team.offices.count,
            limit: subscription.subscription_plan.max_offices,
            percentage: subscription.usage_percentage(:offices)
          },
          cases: {
            used: current_team.works.count,
            limit: subscription.subscription_plan.max_cases,
            percentage: subscription.usage_percentage(:cases)
          }
        }
        
        render json: usage_data
      end

      private

      def set_subscription
        @subscription = current_team.subscription
        
        unless @subscription
          render json: { error: 'Subscription not found' }, status: :not_found
        end
      end

      def subscription_params
        params.require(:subscription).permit(:subscription_plan_id, :status)
      end

      def authorize_subscription_management!
        unless current_admin.team_role(current_team).in?(%w[owner admin])
          render json: { error: 'Not authorized to manage subscription' }, status: :forbidden
        end
      end
    end
  end
end