# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      include CustomerResponses

      before_action :retrieve_customer, only: [:update, :show, :resend_confirmation]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        customers = Customers::QueryService.build_query(
          team: current_team,
          filter_params: filter_by_deleted_params
        )

        serialized = Customers::SerializerService.serialize_customers(customers)
        render_customers_success(
          data: serialized[:data],
          meta: serialized[:meta],
          included: serialized[:included]
        )
      end

      def show
        serialized = Customers::SerializerService.serialize_customer(@customer, action: 'show')
        render_customer_success(
          data: serialized[:data],
          message: 'Cliente encontrado com sucesso',
          included: serialized[:included]
        )
      end

      def create
        result = Customers::CreationService.create_customer(
          params: customers_params,
          current_user: current_user,
          current_team: current_team
        )

        if result.success?
          serialized = Customers::SerializerService.serialize_customer(result.customer)
          render_customer_success(
            data: serialized[:data],
            message: 'Cliente criado com sucesso',
            status: :created
          )
        else
          render_customer_error(errors: result.errors)
        end
      end

      def resend_confirmation
        @customer.update(confirmed_at: nil)
        @customer.send_confirmation_instructions

        render json: {
          success: true,
          message: 'Email de confirmação reenviado com sucesso',
          data: { email: @customer.email }
        }, status: :ok
      end

      def update
        authorize @customer, :update?, policy_class: Admin::CustomerPolicy

        if @customer.update(customers_params)
          handle_email_confirmation_if_needed
          render_successful_update
        else
          render_customer_error(errors: @customer.errors.full_messages)
        end
      end

      def destroy
        if destroy_fully?
          customer = current_team.customers.with_deleted.find(params[:id])
          customer.destroy_fully!
          message = 'Cliente removido permanentemente'
        else
          retrieve_customer
          @customer.destroy
          message = 'Cliente removido com sucesso'
        end

        render json: {
          success: true,
          message: message,
          data: { id: params[:id] }
        }, status: :ok
      end

      def restore
        customer = find_deleted_customer
        authorize customer, :restore?, policy_class: Admin::CustomerPolicy

        if customer.recover
          serialized = Customers::SerializerService.serialize_customer(customer)
          render_customer_success(
            data: serialized[:data],
            message: 'Cliente restaurado com sucesso'
          )
        else
          render_customer_error(errors: customer.errors.full_messages)
        end
      end

      private

      def customers_params
        params.expect(
          customer: [:email, :access_email, :password, :password_confirmation, :status]
        )
      end

      def retrieve_customer
        @customer = current_team.customers.includes(
          profile_customer: [
            :customer, :emails, :phones, :addresses, :bank_accounts,
            :customer_files, :represented_customers, :active_represents
          ]
        ).find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :customer], :"#{action_name}?"
      end

      def normalize_email_param
        params[:customer][:email] ||= params[:customer].delete(:access_email)
      end

      def handle_email_confirmation_if_needed
        @customer.send_confirmation_instructions if @customer.saved_change_to_email?
      end

      def render_successful_update
        serialized = Customers::SerializerService.serialize_customer(@customer)
        render_customer_success(
          data: serialized[:data],
          message: 'Cliente atualizado com sucesso'
        )
      end

      def find_deleted_customer
        current_team.customers.with_deleted.includes(
          profile_customer: [
            :customer, :emails, :phones, :addresses, :bank_accounts,
            :customer_files, :represented_customers, :active_represents
          ]
        ).find(params[:id])
      end
    end
  end
end
