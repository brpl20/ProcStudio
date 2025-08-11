# frozen_string_literal: true

module Api
  module V1
    class LegalEntitiesController < BackofficeController
      before_action :retrieve_entity, only: %i[show update destroy]
      # before_action :perform_authorization, except: %i[]

      # after_action :verify_authorized

      def create
        entity = LegalEntity.new(entity_params)
        entity.team = current_team

        if entity.save
          render json: { data: entity }, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: entity.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e.message }] }
        )
      end

      def show
        render json: { data: @entity }, status: :ok
      end

      def update
        if @entity.update(entity_params)
          render json: { data: @entity }, status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @entity.errors.full_messages }] }
          )
        end
      end

      def destroy
        @entity.destroy
        head :no_content
      end

      private

      def entity_params
        params.require(:legal_entity).permit(
          :name, :trade_name, :cnpj, :registration_number, :registration_date,
          :legal_nature, :size, :team_id,
          contact_addresses_attributes: [:street, :number, :neighborhood, :city, :state, :zip_code, :complement, :address_type, :is_primary],
          contact_phones_attributes: [:number, :phone_type, :is_whatsapp, :is_primary],
          contact_emails_attributes: [:address, :email_type, :is_verified, :is_primary],
          contact_bank_accounts_attributes: [:bank_name, :bank_code, :agency, :account_number, :account_type, :operation, :pix_key]
        )
      end

      def retrieve_entity
        @entity = LegalEntity.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :legal_entity], "#{action_name}?".to_sym
      end
    end
  end
end