# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: %i[update show]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        customers = Customer.all
        render json: CustomerSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        customer = Customer.new(customers_params)
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

      def update
        if @customer.update(customers_params)
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

      private

      def customers_params
        params.require(:customer).permit(
          :email, :password, :password_confirmation
        )
      end

      def retrieve_customer
        @customer = Customer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def perform_authorization
        authorize [:admin, :customer], "#{action_name}?".to_sym
      end
    end
  end
end
