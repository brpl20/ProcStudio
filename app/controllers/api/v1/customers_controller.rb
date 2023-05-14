# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      def index
        customers = Customer.all
        render json: CustomersSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end
    end
  end
end
