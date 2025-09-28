# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    # rubocop:disable Metrics/ClassLength
    class ProfileCustomersController < BackofficeController
      include InputSanitizer

      before_action :load_active_storage_url_options unless Rails.env.production?
      before_action :validate_input_safety?, only: [:create, :update]

      before_action :profile_customer, only: [:update, :show]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        profile_customers = ProfileCustomerFilter.retrieve_customers(current_team)

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          profile_customers = profile_customers.public_send("filter_by_#{key}", value.strip)
        end

        serialized = ProfileCustomerSerializer.new(
          profile_customers,
          meta: {
            total_count: profile_customers.offset(nil).limit(nil).count
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Perfis de clientes listados com sucesso',
          data: serialized[:data],
          meta: serialized[:meta]
        }, status: :ok
      end

      def show
        render json: {
          success: true,
          message: 'Perfil de cliente encontrado com sucesso',
          data: ProfileCustomerSerializer.new(
            @profile_customer,
            { params: { action: 'show' } }
          ).serializable_hash[:data]
        }, status: :ok
      end

      def create
        profile_customer = ProfileCustomer.new(profile_customers_params)
        profile_customer.created_by_id = current_user.id

        if profile_customer.save
          # Reload to ensure all associations are loaded
          profile_customer.reload

          # Associate the customer with the current team
          if profile_customer.customer.present? && current_team.present?
            TeamCustomer.create!(
              team: current_team,
              customer: profile_customer.customer,
              customer_email: profile_customer.customer.email
            )
          end

          if truthy_param?(:issue_documents)
            ProfileCustomers::CreateDocumentService.call(profile_customer,
                                                         current_user)
          end

          render json: {
            success: true,
            message: 'Perfil de cliente criado com sucesso',
            data: ProfileCustomerSerializer.new(
              profile_customer,
              params: { action: 'show' }
            ).serializable_hash[:data]
          }, status: :created
        else
          # More detailed validation error logging
          Rails.logger.error 'ProfileCustomer validation failed:'
          Rails.logger.error "Errors: #{profile_customer.errors.full_messages}"
          Rails.logger.error "Attributes: #{profile_customers_params.inspect}"

          error_messages = profile_customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordInvalid => e
        # Handle validation errors from associated models (like Customer)
        Rails.logger.error "ProfileCustomer associated model validation error: #{e.message}"
        Rails.logger.error "Record errors: #{e.record.errors.full_messages}" if e.record

        render json: {
          success: false,
          message: "Validation error: #{e.message}",
          errors: e.record&.errors&.full_messages || [e.message]
        }, status: :unprocessable_content
      rescue ArgumentError => e
        # Handle invalid enum values
        Rails.logger.error "ProfileCustomer invalid argument: #{e.message}"

        render json: {
          success: false,
          message: e.message,
          errors: [e.message]
        }, status: :unprocessable_content
      rescue ActiveRecord::RecordNotUnique => e
        # Handle database uniqueness constraint violations
        Rails.logger.error "ProfileCustomer uniqueness constraint violation: #{e.message}"

        render json: {
          success: false,
          message: 'Este email já está em uso. Tente um email diferente.',
          errors: ['Duplicate record: email already exists']
        }, status: :unprocessable_content
      rescue ActionController::ParameterMissing => e
        # Handle missing required parameters
        Rails.logger.error "ProfileCustomer missing parameters: #{e.message}"

        render json: {
          success: false,
          message: "Required parameter missing: #{e.param}",
          errors: ["Missing parameter: #{e.param}"]
        }, status: :bad_request
      rescue StandardError => e
        # Detailed error logging for debugging
        Rails.logger.error "ProfileCustomer creation unexpected error: #{e.class} - #{e.message}"
        Rails.logger.error "Backtrace: #{e.backtrace.first(15).join("\n")}" if e.backtrace
        Rails.logger.error "Parameters: #{profile_customers_params.inspect}"

        # In development, show more details; in production, keep generic
        if Rails.env.development?
          render json: {
            success: false,
            message: "Development Error: #{e.class} - #{e.message}",
            errors: [e.message],
            backtrace: e.backtrace.first(10)
          }, status: :internal_server_error
        else
          render json: {
            success: false,
            message: 'Erro interno do servidor. Tente novamente ou contacte o suporte.',
            errors: ['Internal server error']
          }, status: :internal_server_error
        end
      end

      def update
        authorize @profile_customer, :update?, policy_class: Admin::CustomerPolicy

        if @profile_customer.update(profile_customers_params)
          if truthy_param?(:regenerate_documents)
            ProfileCustomers::CreateDocumentService.call(@profile_customer,
                                                         @current_admin)
          end

          if @profile_customer.customer&.saved_change_to_email?
            @profile_customer.customer.send_confirmation_instructions
          end

          render json: {
            success: true,
            message: 'Perfil de cliente atualizado com sucesso',
            data: ProfileCustomerSerializer.new(
              @profile_customer,
              params: { action: 'show' }
            ).serializable_hash[:data]
          }, status: :ok
        else
          error_messages = @profile_customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordInvalid => e
        # Handle validation errors from associated models
        Rails.logger.error "ProfileCustomer update validation error: #{e.message}"

        render json: {
          success: false,
          message: "Validation error: #{e.message}",
          errors: e.record&.errors&.full_messages || [e.message]
        }, status: :unprocessable_content
      rescue ActiveModel::UnknownAttributeError, ArgumentError => e
        # Handle unknown attributes and invalid enum values
        Rails.logger.error "ProfileCustomer attribute error: #{e.message}"

        render json: {
          success: false,
          message: "Invalid attribute: #{e.message}",
          errors: [e.message]
        }, status: :unprocessable_content
      rescue ActionController::ParameterMissing => e
        # Handle missing required parameters
        Rails.logger.error "ProfileCustomer missing parameters: #{e.message}"

        render json: {
          success: false,
          message: "Required parameter missing: #{e.param}",
          errors: ["Missing parameter: #{e.param}"]
        }, status: :bad_request
      rescue StandardError => e
        # Log error for debugging
        Rails.logger.error "ProfileCustomer update unexpected error: #{e.class} - #{e.message}"
        Rails.logger.error "Backtrace: #{e.backtrace.first(10).join("\n")}" if e.backtrace

        # In development, show more details; in production, keep generic
        if Rails.env.development?
          render json: {
            success: false,
            message: "Development Error: #{e.class} - #{e.message}",
            errors: [e.message],
            backtrace: e.backtrace.first(5)
          }, status: :unprocessable_content
        else
          render json: {
            success: false,
            message: 'Erro ao atualizar perfil. Por favor, verifique os dados enviados.',
            errors: ['Invalid data provided']
          }, status: :unprocessable_content
        end
      end

      def destroy
        if destroy_fully?
          profile_customer = ProfileCustomer.with_deleted.find(params[:id])
          profile_customer.destroy_fully!
          message = 'Perfil de cliente removido permanentemente'
        else
          profile_customer = ProfileCustomer.find(params[:id])
          profile_customer.destroy
          message = 'Perfil de cliente removido com sucesso'
        end

        render json: {
          success: true,
          message: message,
          data: { id: params[:id] }
        }, status: :ok
      end

      def restore
        profile_customer = ProfileCustomer.with_deleted.find(params[:id])
        authorize profile_customer, :restore?, policy_class: Admin::CustomerPolicy

        if profile_customer.recover
          render json: {
            success: true,
            message: 'Perfil de cliente restaurado com sucesso',
            data: ProfileCustomerSerializer.new(
              profile_customer,
              params: { action: 'show' }
            ).serializable_hash[:data]
          }, status: :ok
        else
          error_messages = profile_customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_content
        end
      end

      private

      def profile_customer
        @profile_customer = ProfileCustomer.with_deleted.find(params[:id]) if truthy_param?(:include_deleted)
        @profile_customer ||= ProfileCustomerFilter.retrieve_customer(params[:id], current_team)
      end

      def profile_customers_params
        params.require(:profile_customer).permit(
          :customer_type, :name, :status, :customer_id, :last_name,
          :cpf, :rg, :birth, :gender, :cnpj,
          :civil_status, :nationality,
          :capacity, :profession,
          :company,
          :number_benefit,
          :nit, :mother_name,
          :inss_password,
          :accountant_id,
          addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city, :state],
          bank_accounts_attributes: [:id, :bank_name, :account_type, :agency, :account, :operation, :pix],
          customer_attributes: [:id, :email, :access_email, :password, :password_confirmation],
          phones_attributes: [:id, :phone_number],
          emails_attributes: [:id, :email],
          represent_attributes: [:id, :representor_id],
          customer_files_attributes: [:id, :file_description]
        )
        # rubocop:enable Rails/StrongParametersExpect
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
