# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    class ProfileCustomersController < BackofficeController
      include InputSanitizer
      include ProfileCustomerResponses
      include AttachmentTransferable

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
        service = ProfileCustomers::CreationService.new(
          current_user: current_user,
          current_team: current_team
        )

        options = { issue_documents: truthy_param?(:issue_documents) }
        result = service.call(profile_customers_params, options)

        if result.success?
          profile_customer_success_response(
            'Perfil de cliente criado com sucesso',
            result.profile_customer,
            :created
          )
        else
          profile_customer_error_response(
            result.errors.first,
            result.errors
          )
        end
      rescue StandardError => e
        handle_profile_customer_create_errors(e, profile_customers_params)
      end

      def update
        authorize @profile_customer, :update?, policy_class: Admin::CustomerPolicy

        service = ProfileCustomers::UpdateService.new(
          profile_customer: @profile_customer,
          current_admin: @current_admin
        )

        options = { regenerate_documents: truthy_param?(:regenerate_documents) }
        result = service.call(profile_customers_params, options)

        if result.success?
          profile_customer_success_response(
            'Perfil de cliente atualizado com sucesso',
            result.profile_customer
          )
        else
          profile_customer_error_response(
            result.errors.first,
            result.errors
          )
        end
      rescue StandardError => e
        handle_profile_customer_update_errors(e)
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

      def upload_attachment
        profile_customer  # This calls the private method to get @profile_customer
        authorize @profile_customer, :update?, policy_class: Admin::CustomerPolicy

        unless params[:attachment].present?
          return profile_customer_error_response(
            'Arquivo não fornecido',
            ['Attachment file is required']
          )
        end

        begin
          # Generic customer attachment
          file_metadata = S3Manager.upload(
            params[:attachment],
            model: @profile_customer,
            user_profile: current_user.user_profile,
            metadata: {
              description: params[:description],
              document_date: params[:document_date],
              file_type: 'customer_attachment'
            }
          )

          profile_customer_success_response(
            'Anexo enviado com sucesso',
            {
              id: @profile_customer.id,
              file_metadata_id: file_metadata.id,
              filename: file_metadata.filename,
              url: file_metadata.url,
              byte_size: file_metadata.byte_size,
              content_type: file_metadata.content_type
            }
          )
        rescue StandardError => e
          Rails.logger.error "Customer attachment upload failed: #{e.message}"
          profile_customer_internal_error_response(e, 'Erro ao fazer upload do anexo')
        end
      end

      def remove_attachment
        profile_customer  # This calls the private method to get @profile_customer
        authorize @profile_customer, :update?, policy_class: Admin::CustomerPolicy

        begin
          FileMetadata.where(attachable: @profile_customer, id: params[:attachment_id]).destroy_all

          profile_customer_success_response(
            'Anexo removido com sucesso',
            { id: @profile_customer.id, attachment_id: params[:attachment_id] }
          )
        rescue ActiveRecord::RecordNotFound
          profile_customer_not_found_response
        rescue StandardError => e
          profile_customer_internal_error_response(e, 'Erro ao remover anexo')
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
  end
end
