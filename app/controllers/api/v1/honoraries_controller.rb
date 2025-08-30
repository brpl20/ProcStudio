# frozen_string_literal: true

module Api
  module V1
    class HonorariesController < BackofficeController
      before_action :set_parent_resource
      before_action :set_honorary, only: [:show, :update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        honoraries = @parent.honoraries.includes(:components, :legal_cost)

        honoraries = honoraries.where(status: params[:status]) if params[:status].present?

        render json: HonorarySerializer.new(
          honoraries,
          include: [:components, :legal_cost],
          meta: {
            total_count: honoraries.count,
            total_value: honoraries.sum(&:total_estimated_value)
          }
        ), status: :ok
      end

      def show
        render json: HonorarySerializer.new(
          @honorary,
          include: [:components, :legal_cost]
        ), status: :ok
      end

      def create
        honorary = @parent.honoraries.build(honorary_params)

        # If parent is a procedure, also set the work reference
        honorary.work = @parent.is_a?(Procedure) ? @parent.work : @parent

        if honorary.save
          render json: HonorarySerializer.new(honorary), status: :created
        else
          render json: { errors: honorary.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @honorary.update(honorary_params)
          render json: HonorarySerializer.new(@honorary), status: :ok
        else
          render json: { errors: @honorary.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @honorary.destroy
        head :no_content
      end

      # Custom endpoints
      def summary
        honorary = @parent.honoraries.find(params[:honorary_id])

        render json: {
          data: {
            total_estimated_value: honorary.total_estimated_value,
            components_count: honorary.components.active.count,
            is_global: honorary.is_global?,
            is_procedure_specific: honorary.is_procedure_specific?,
            legal_costs_summary: honorary.legal_cost&.summary
          }
        }, status: :ok
      end

      private

      def set_parent_resource
        if params[:procedure_id].present?
          work = team_scoped(Work).find(params[:work_id])
          @parent = work.procedures.find(params[:procedure_id])
        else
          @parent = team_scoped(Work).find(params[:work_id])
        end
      end

      def set_honorary
        @honorary = @parent.honoraries.find(params[:id])
      end

      def honorary_params
        params.expect(
          honorary: [:name,
                     :description,
                     :status,
                     :honorary_type,
                     :fixed_honorary_value,
                     :percent_honorary_value,
                     :parcelling,
                     :parcelling_value,
                     { components_attributes: [
                       :id,
                       :component_type,
                       :details,
                       :active,
                       :position,
                       :_destroy
                     ] }]
        )
      end

      def perform_authorization
        authorize Honorary
      end
    end
  end
end
