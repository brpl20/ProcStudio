# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: %i[update show destroy resend_confirmation]
      before_action :perform_authorization, except: %i[update]

      after_action :verify_authorized

      def index
        customers = ::Customer.all
        render json: CustomerSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        customer = ::Customer.new(customers_params)
        customer.created_by_id = current_user.id
        if customer.save

          render json: CustomerSerializer.new(
            customer
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: customer.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def resend_confirmation
        @customer.update(confirmed_at: nil)
        @customer.send_confirmation_instructions
        head :ok
      end

      def update
        authorize @customer, :update?, policy_class: Admin::CustomerPolicy

        if @customer.update(customers_params)
          @customer.send_confirmation_instructions if @customer.saved_change_to_email?

          render json: CustomerSerializer.new(
            @customer
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @customer.errors.full_messages }] }
          )
        end
      end

      def show
        render json: CustomerSerializer.new(
          @customer
        ), status: :ok
      end

      def destroy
        @customer.destroy
      end

      private

      def customers_params
        params.require(:customer).permit(
          :email, :password, :password_confirmation
        )
      end

      def retrieve_customer
        @customer = ::Customer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def perform_authorization
        authorize [:admin, :customer], "#{action_name}?".to_sym
      end
    end
  end
end
