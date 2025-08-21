# frozen_string_literal: true

module Api
  module V1
    class OfficesController < BackofficeController
      before_action :retrieve_office, only: [:show, :update]
      before_action :retrieve_deleted_office, only: [:restore]
      before_action :perform_authorization, except: [:with_lawyers]

      after_action :verify_authorized

      def index
        @offices = OfficeFilter.retrieve_offices

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          @offices = @offices.public_send("filter_by_#{key}", value.strip)
        end

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
          head :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @office.errors.full_messages }] }
          )
        end
      end

      def destroy
        if destroy_fully?
          Office.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_office
          @office.destroy
        end
      end

      def with_lawyers
        authorize [:admin, :office], :index?

        offices = OfficeFilter.retrieve_offices_with_lawyers
        render json: OfficeWithLawyersSerializer.new(
          offices
        ), status: :ok
      end

      def restore
        if @office.recover
          head :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @office.errors.full_messages }] }
          )
        end
      end

      private

      def retrieve_office
        @office = OfficeFilter.retrieve_office(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      def retrieve_deleted_office
        @office = Office.with_deleted.find(params[:id])
      end

      def offices_params
        params.expect(
          office: [:name, :cnpj,
                   :oab, :society,
                   :foundation, :site,
                   :zip_code, :street,
                   :number, :neighborhood,
                   :city, :state,
                   :logo,
                   :accounting_type,
                   :office_type_id,
                   :responsible_lawyer_id,
                   { phones_attributes: [:id, :phone_number],
                     emails_attributes: [:id, :email],
                     bank_accounts_attributes: [:id, :bank_name, :type_account, :agency, :account, :operation, :pix] }]
        )
      end

      def perform_authorization
        authorize [:admin, :office], :"#{action_name}?"
      end
    end
  end
end
