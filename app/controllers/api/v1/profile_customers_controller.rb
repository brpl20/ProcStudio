# frozen_string_literal: true

require 'docx'
require 'tempfile'
module Api
  module V1
    class ProfileCustomersController < BackofficeController
      before_action :retrieve_customer, only: %i[update show]

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
        @profile_customer = ProfileCustomer.new(profile_customers_params)

        # criação para fins de testes
        email = params['profile_customer']['emails_attributes'].first
        @profile_customer.customer = Customer.create(email: email['email'], password: 'Cliente123#')

        p @profile_customer.customer

        if @profile_customer.save
          render json: @profile_customer, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @profile_customer.errors.full_messages }] }
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
          head :ok
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
          addresses_attributes: %i[id description zip_code street number neighborhood city state],
          bank_accounts_attributes: %i[id bank_name type_account agency account operation pix],
          customer_attributes: %i[id email password password_confirmation],
          phones_attributes: %i[id phone_number],
          emails_attributes: %i[id email]
        )
      end
    end
  end
end
