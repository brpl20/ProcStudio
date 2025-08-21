# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: [:update, :show, :resend_confirmation]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        customers = current_team.customers

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          customers = customers.public_send("filter_by_#{key}", value.strip)
        end

        render json: CustomerSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def show
        render json: CustomerSerializer.new(
          @customer
        ), status: :ok
      end

      def create
        customer = ::Customer.new(customers_params)
        customer.created_by_id = current_user&.id

        if customer.save
          # Associar customer ao team atual
          TeamCustomer.create!(
            team: current_team,
            customer: customer,
            customer_email: customer.email
          )

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
        Rails.logger.error "Customer creation error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        render(
          status: :bad_request,
          json: { errors: [{ code: e.message }] }
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

      def destroy
        if destroy_fully?
          customer = current_team.customers.with_deleted.find(params[:id])
          customer.destroy_fully!
        else
          retrieve_customer
          @customer.destroy
        end
      end

      def restore
        customer = current_team.customers.with_deleted.find(params[:id])
        authorize customer, :restore?, policy_class: Admin::CustomerPolicy

        if customer.recover
          render json: CustomerSerializer.new(
            customer
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: customer.errors.full_messages }] }
          )
        end
      end

      private

      def customers_params
        params.expect(
          customer: [:email, :access_email, :password, :password_confirmation, :status]
        )
      end

      def retrieve_customer
        @customer = current_team.customers.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :customer], :"#{action_name}?"
      end

      def normalize_email_param
        params[:customer][:email] ||= params[:customer].delete(:access_email)
      end
    end
  end
end
