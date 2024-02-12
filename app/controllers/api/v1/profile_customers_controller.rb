# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    class ProfileCustomersController < BackofficeController
      unless Rails.env.production?
        before_action do
          ActiveStorage::Current.url_options = { host: request.base_url }
        end
      end
      before_action :retrieve_customer, only: %i[update show destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        profile_customers = ProfileCustomerFilter.retrieve_customers

        render json: ProfileCustomerSerializer.new(
          profile_customers,
          meta: {
            total_count: profile_customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        profile_customer = ProfileCustomer.new(profile_customers_params)
        if profile_customer.save
          ProfileCustomers::CreateDocumentService.call(profile_customer, @current_admin)
          render json: ProfileCustomerSerializer.new(
            profile_customer,
            params: { action: 'show' }
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: profile_customer.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @profile_customer.update(profile_customers_params)
          ProfileCustomers::CreateDocumentService.call(@profile_customer, @current_admin) if truthy_param?(:regenerate_documents)
          render json: ProfileCustomerSerializer.new(
            @profile_customer,
            params: { action: 'show' }
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @profile_customer.errors.full_messages }] }
          )
        end
      end

      def show
        render json: ProfileCustomerSerializer.new(
          @profile_customer,
          { params: { action: 'show' } }
        ), status: :ok
      end

      def destroy
        @profile_customer.destroy
      end

      private

      def retrieve_customer
        @profile_customer = ProfileCustomerFilter.retrieve_customer(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
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
          addresses_attributes: %i[id description zip_code street number neighborhood city state],
          bank_accounts_attributes: %i[id bank_name type_account agency account operation pix],
          customer_attributes: %i[id email password password_confirmation],
          phones_attributes: %i[id phone_number],
          emails_attributes: %i[id email],
          represent_attributes: %i[id representor_id],
          customer_files_attributes: %i[id file_description]
        )
      end

      def perform_authorization
        authorize [:admin, :work], "#{action_name}?".to_sym
      end
    end
  end
end
