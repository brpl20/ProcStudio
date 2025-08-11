# frozen_string_literal: true

module Api
  module V1
    class CustomersController < BackofficeController
      before_action :retrieve_customer, only: %i[update show resend_confirmation]
      before_action :perform_authorization, except: %i[update]

      after_action :verify_authorized

      def index
        customers = current_team ? ::Customer.by_team(current_team) : ::Customer.all

        filter_by_deleted_params.each do |key, value|
          next unless value.present?

          customers = customers.public_send("filter_by_#{key}", value.strip)
        end

        render json: CustomerSerializer.new(
          customers,
          meta: {
            total_count: customers.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        customer = ::Customer.new(customers_params)
        customer.created_by_id = current_user.id
        customer.team = current_team
        if customer.save

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
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def create_with_profile
        ActiveRecord::Base.transaction do
          # Determine if it's individual or legal entity
          profile_type = customer_profile_params[:customer_type] == 'legal_person' ? 'LegalEntity' : 'IndividualEntity'
          
          # Create the entity first
          if profile_type == 'IndividualEntity'
            entity = IndividualEntity.create!(individual_entity_params)
          else
            entity = LegalEntity.create!(legal_entity_params)
          end
          
          # Create customer with polymorphic reference
          customer = ::Customer.new(customers_params)
          customer.created_by_id = current_user.id
          customer.team = current_team
          customer.profile = entity
          
          if customer.save
            render json: CustomerSerializer.new(customer), status: :created
          else
            render(
              status: :bad_request,
              json: { errors: [{ code: customer.errors.full_messages }] }
            )
          end
        end
      rescue StandardError => e
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

      def show
        render json: CustomerSerializer.new(
          @customer
        ), status: :ok
      end

      def destroy
        if destroy_fully?
          ::Customer.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_customer
          @customer.destroy
        end
      end

      def restore
        customer = ::Customer.with_deleted.find(params[:id])
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
        params.require(:customer).permit(
          :email, :access_email, :password, :password_confirmation, :status, :team_id
        )
      end

      def customer_profile_params
        params.require(:profile).permit(:customer_type)
      end

      def individual_entity_params
        params.require(:profile).permit(
          :name, :last_name, :cpf, :rg, :birth, :gender, :nationality,
          :civil_status, :capacity, :mother_name, :profession,
          :number_benefit, :nit, :inss_password, :team_id,
          contact_addresses_attributes: [:street, :number, :neighborhood, :city, :state, :zip_code, :complement, :address_type, :is_primary],
          contact_phones_attributes: [:number, :phone_type, :is_whatsapp, :is_primary],
          contact_emails_attributes: [:address, :email_type, :is_verified, :is_primary],
          contact_bank_accounts_attributes: [:bank_name, :bank_code, :agency, :account_number, :account_type, :operation, :pix_key]
        )
      end

      def legal_entity_params
        params.require(:profile).permit(
          :name, :trade_name, :cnpj, :registration_number, :registration_date,
          :legal_nature, :size, :team_id,
          contact_addresses_attributes: [:street, :number, :neighborhood, :city, :state, :zip_code, :complement, :address_type, :is_primary],
          contact_phones_attributes: [:number, :phone_type, :is_whatsapp, :is_primary],
          contact_emails_attributes: [:address, :email_type, :is_verified, :is_primary],
          contact_bank_accounts_attributes: [:bank_name, :bank_code, :agency, :account_number, :account_type, :operation, :pix_key]
        )
      end

      def retrieve_customer
        scope = current_team ? ::Customer.by_team(current_team) : ::Customer
        @customer = scope.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :customer], "#{action_name}?".to_sym
      end

      def normalize_email_param
        params[:customer][:email] ||= params[:customer].delete(:access_email)
      end
    end
  end
end
