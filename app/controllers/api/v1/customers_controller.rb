# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: %i[update show]

      def index
        customers = Customer.all
        render json: CustomersSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        customer = Customer.new(customers_params)
        if customer.save
          render json: CustomersSerializer.new(
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
          render json: CustomersSerializer.new(
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
        render json: CustomersSerializer.new(
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
    end
  end
end
