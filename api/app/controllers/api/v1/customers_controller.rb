# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: [:update, :show, :resend_confirmation]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        customers = current_team.customers.includes(
          profile_customer: [
            :customer, :emails, :phones, :addresses, :bank_accounts,
            :customer_files, :represented_customers, :active_represents
          ]
        )

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          customers = customers.public_send("filter_by_#{key}", value.strip)
        end

        serialized = CustomerSerializer.new(
          customers,
          include: [:profile_customer],
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Clientes listados com sucesso',
          data: serialized[:data],
          included: serialized[:included],
          meta: serialized[:meta]
        }, status: :ok
      end

      def show
        serialized = CustomerSerializer.new(
          @customer,
          include: [:profile_customer],
          params: { action: 'show' }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Cliente encontrado com sucesso',
          data: serialized[:data],
          included: serialized[:included]
        }, status: :ok
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

          render json: {
            success: true,
            message: 'Cliente criado com sucesso',
            data: CustomerSerializer.new(customer, include: [:profile_customer]).serializable_hash[:data]
          }, status: :created
        else
          error_messages = customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Customer creation error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        error_message = 'Erro ao criar cliente. Tente novamente.'
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :internal_server_error
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
          @customer.send_confirmation_instructions if @customer.saved_change_to_email?

          render json: {
            success: true,
            message: 'Cliente atualizado com sucesso',
            data: CustomerSerializer.new(@customer, include: [:profile_customer]).serializable_hash[:data]
          }, status: :ok
        else
          error_messages = @customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
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
        customer = current_team.customers.with_deleted.includes(
          profile_customer: [
            :customer, :emails, :phones, :addresses, :bank_accounts,
            :customer_files, :represented_customers, :active_represents
          ]
        ).find(params[:id])
        authorize customer, :restore?, policy_class: Admin::CustomerPolicy

        if customer.recover
          render json: {
            success: true,
            message: 'Cliente restaurado com sucesso',
            data: CustomerSerializer.new(customer, include: [:profile_customer]).serializable_hash[:data]
          }, status: :ok
        else
          error_messages = customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
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
    end
  end
end
