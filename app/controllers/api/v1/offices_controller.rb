# frozen_string_literal: true

module Api
  module V1
    class OfficesController < BackofficeController
      before_action :retrieve_office, only: %i[show update destroy]

      def index
        @offices = OfficeFilter.retrieve_offices
        render json: OfficeSerializer.new(
          @offices,
          meta: {
            total_count: @offices.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def show
        render json: OfficeSerializer.new(
          @office,
          { params: { action: 'show' } }
        ), status: :ok
      end

      def create
        @office = Office.new(offices_params)
        if @office.save
          render json: @office, status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @office.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @office.update(offices_params)
          render json: OfficeSerializer.new(
            @office
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @office.errors.full_messages }] }
          )
        end
      end

      def destroy
        if @office.destroy
          render head :not_found
        else
          render json: { errors: office.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def retrieve_office
        @office = OfficeFilter.retrieve_office(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def offices_params
        params.require(:office).permit(
          :name, :cnpj,
          :oab, :society,
          :foundation, :site,
          :cep, :street,
          :number, :neighborhood,
          :city, :state,
          :logo,
          :office_type_id,
          phones_attributes: %i[id phone_number],
          emails_attributes: %i[id email],
          bank_accounts_attributes: %i[id bank_name type_account agency account operation]
        )
      end
    end
  end
end
