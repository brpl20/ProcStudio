# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    class ProfileCustomersController < BackofficeController
      before_action :load_active_storage_url_options unless Rails.env.production?

      before_action :profile_customer, only: %i[update show]
      before_action :perform_authorization, except: %i[update]

      after_action :verify_authorized

      def index
        profile_customers = ProfileCustomerFilter.retrieve_customers(current_team)

        filter_by_deleted_params.each do |key, value|
          next unless value.present?

          profile_customers = profile_customers.public_send("filter_by_#{key}", value.strip)
        end

        render json: ProfileCustomerSerializer.new(
          profile_customers,
          meta: {
            total_count: profile_customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        profile_customer = ProfileCustomer.new(profile_customers_params)
        profile_customer.created_by_id = current_user.id
        profile_customer.team = current_team
        if profile_customer.save
          ProfileCustomers::CreateDocumentService.call(profile_customer, current_user) if truthy_param?(:issue_documents)

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
        authorize @profile_customer, :update?, policy_class: Admin::CustomerPolicy

        if @profile_customer.update(profile_customers_params)
          ProfileCustomers::CreateDocumentService.call(@profile_customer, @current_admin) if truthy_param?(:regenerate_documents)

          @profile_customer.customer.send_confirmation_instructions if @profile_customer.customer&.saved_change_to_email?

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
        if destroy_fully?
          ProfileCustomer.with_deleted.find(params[:id]).destroy_fully!
        else
          profile_customer
          @profile_customer.destroy
        end
      end

      def restore
        profile_customer = ProfileCustomer.with_deleted.find(params[:id])
        authorize profile_customer, :restore?, policy_class: Admin::CustomerPolicy

        if profile_customer.recover
          render json: ProfileCustomerSerializer.new(
            profile_customer,
            params: { action: 'show' }
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: profile_customer.errors.full_messages }] }
          )
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
          :team_id,
          addresses_attributes: %i[id description zip_code street number neighborhood city state],
          bank_accounts_attributes: %i[id bank_name type_account agency account operation pix],
          customer_attributes: %i[id email access_email password password_confirmation team_id],
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
