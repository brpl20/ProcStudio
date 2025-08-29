# frozen_string_literal: true

module Api
  module V1
    class HonoraryComponentsController < BackofficeController
      before_action :set_honorary
      before_action :set_component, only: [:show, :update, :destroy, :toggle_active]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        components = @honorary.components.ordered

        components = components.active if params[:active] == 'true'
        components = components.where(component_type: params[:component_type]) if params[:component_type].present?

        render json: HonoraryComponentSerializer.new(
          components,
          meta: {
            total_count: components.count,
            total_value: components.sum { |c| c.calculate_total || 0 }
          }
        ), status: :ok
      end

      def show
        render json: HonoraryComponentSerializer.new(@component), status: :ok
      end

      def create
        component = @honorary.add_component(
          params[:component][:component_type],
          params[:component][:details]
        )

        if component.persisted?
          render json: HonoraryComponentSerializer.new(component), status: :created
        else
          render json: { errors: component.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @component.update(component_params)
          render json: HonoraryComponentSerializer.new(@component), status: :ok
        else
          render json: { errors: @component.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @component.destroy
        head :no_content
      end

      # Custom endpoints
      def toggle_active
        @component.update!(active: !@component.active)
        render json: HonoraryComponentSerializer.new(@component), status: :ok
      end

      def reorder
        params[:order].each_with_index do |id, index|
          @honorary.components.find(id).update(position: index + 1)
        end

        head :no_content
      end

      def calculate
        component = @honorary.components.find(params[:component_id])

        render json: {
          data: {
            component_type: component.component_type,
            calculated_value: component.calculate_total,
            formatted_details: component.formatted_details
          }
        }, status: :ok
      end

      private

      def set_honorary
        work = team_scoped(Work).find(params[:work_id])
        if params[:procedure_id].present?
          procedure = work.procedures.find(params[:procedure_id])
          @honorary = procedure.honoraries.find(params[:honorary_id])
        else
          @honorary = work.honoraries.find(params[:honorary_id])
        end
      end

      def set_component
        @component = @honorary.components.find(params[:id])
      end

      def component_params
        params.expect(
          component: [:component_type,
                      :active,
                      :position,
                      { details: {} }]
        )
      end

      def perform_authorization
        authorize HonoraryComponent
      end
    end
  end
end
