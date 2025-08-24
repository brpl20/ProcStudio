# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    class ProfileCustomersController < BackofficeController
      before_action :load_active_storage_url_options unless Rails.env.production?

      before_action :profile_customer, only: [:update, :show]
      before_action :perform_authorization, except: [:update]

      after_action :verify_authorized

      def index
        profile_customers = ProfileCustomerFilter.retrieve_customers

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
          error_messages = profile_customer.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "ProfileCustomer creation error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        error_message = 'Erro ao criar perfil de cliente. Tente novamente.'
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :internal_server_error
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
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if destroy_fully?
          profile_customer = ProfileCustomer.with_deleted.find(params[:id])
          profile_customer.destroy_fully!
          message = 'Perfil de cliente removido permanentemente'
        else
          @profile_customer.destroy
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
          }, status: :unprocessable_entity
        end
      end

      private

      def profile_customer
        @profile_customer = ProfileCustomer.with_deleted.find(params[:id]) if truthy_param?(:include_deleted)
        @profile_customer ||= ProfileCustomerFilter.retrieve_customer(params[:id])
      end

      def profile_customers_params
        params.expect(
          profile_customer: [:customer_type, :name, :status, :customer_id, :last_name,
                             :cpf, :rg, :birth, :gender, :cnpj,
                             :civil_status, :nationality,
                             :capacity, :profession,
                             :company,
                             :number_benefit,
                             :nit, :mother_name,
                             :inss_password,
                             :accountant_id,
                             { addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city, :state],
                               bank_accounts_attributes: [:id, :bank_name, :type_account, :agency, :account, :operation,
                                                          :pix],
                               customer_attributes: [:id, :email, :access_email, :password, :password_confirmation],
                               phones_attributes: [:id, :phone_number],
                               emails_attributes: [:id, :email],
                               represent_attributes: [:id, :representor_id],
                               customer_files_attributes: [:id, :file_description] }]
        )
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
