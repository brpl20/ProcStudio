# frozen_string_literal: true

module Api
  module V1
    class OfficeTypesController < BackofficeController
      before_action :retrieve_office_type, only: [:update, :show, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      # GET api/v1/office_types
      def index
        office_types = OfficeType.all

        render json: OfficeTypeSerializer.new(
          office_types,
          meta: {
            total_count: office_types.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      # GET api/v1/office_types/:id
      def show
        render json: OfficeTypeSerializer.new(@office_type), status: :ok
      end

      # POST api/v1/office_types
      def create
        office_type = OfficeType.new(office_types_params)
        if office_type.save
          render json: OfficeTypeSerializer.new(
            office_type
          ), status: :created
        else
          render(
            status: :unprocessable_entity,
            json: { errors: [{ code: office_type.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      # PUT api/v1/office_types/:id
      def update
        if @office_type.update(office_types_params)
          render json: OfficeTypeSerializer.new(@office_type), status: :ok
        else
          render(
            status: :unprocessable_entity,
            json: { errors: [{ code: @office_type.errors.full_messages }] }
          )
        end
      end

      # DELETE api/v1/office_types/:id
      def destroy
        @office_type.destroy
      end

      private

      def office_types_params
        params.expect(office_type: [:description])
      end

      def retrieve_office_type
        @office_type = OfficeType.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :office], :"#{action_name}?"
      end
    end
  end
end
