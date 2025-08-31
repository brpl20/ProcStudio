# frozen_string_literal: true

module Api
  module V1
    class LegalCostTypesController < BackofficeController
      before_action :set_legal_cost_type, only: [:show, :update, :destroy]

      def index
        @legal_cost_types = LegalCostType
                              .available_for(current_team)
                              .ordered
                              .includes(:team)

        @legal_cost_types = @legal_cost_types.by_category(params[:category]) if params[:category].present?

        render json: {
          success: true,
          message: 'Tipos de custos legais listados com sucesso',
          data: @legal_cost_types.map { |type| serialize_cost_type(type) }
        }, status: :ok
      end

      def show
        render json: {
          success: true,
          message: 'Tipo de custo legal encontrado com sucesso',
          data: serialize_cost_type(@legal_cost_type)
        }, status: :ok
      end

      def create
        @legal_cost_type = current_team.legal_cost_types.build(legal_cost_type_params)
        @legal_cost_type.is_system = false
        @legal_cost_type.team = current_team

        if @legal_cost_type.save
          render json: {
            success: true,
            message: 'Tipo de custo legal criado com sucesso',
            data: serialize_cost_type(@legal_cost_type)
          }, status: :created
        else
          error_messages = @legal_cost_type.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        unless @legal_cost_type.editable?
          return render json: {
            success: false,
            message: 'Tipos do sistema não podem ser editados',
            errors: ['Tipos do sistema não podem ser editados']
          }, status: :forbidden
        end

        if @legal_cost_type.update(legal_cost_type_params)
          render json: {
            success: true,
            message: 'Tipo de custo legal atualizado com sucesso',
            data: serialize_cost_type(@legal_cost_type)
          }, status: :ok
        else
          error_messages = @legal_cost_type.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        unless @legal_cost_type.deletable?
          error_message = if @legal_cost_type.system?
                            'Tipos do sistema não podem ser excluídos'
                          else
                            'Tipo não pode ser excluído pois possui lançamentos associados'
                          end

          return render json: {
            success: false,
            message: error_message,
            errors: [error_message]
          }, status: :forbidden
        end

        if @legal_cost_type.destroy
          render json: {
            success: true,
            message: 'Tipo de custo legal excluído com sucesso',
            data: nil
          }, status: :ok
        else
          error_messages = @legal_cost_type.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao excluir tipo de custo legal',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_legal_cost_type
        @legal_cost_type = LegalCostType.available_for(current_team).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Tipo de custo legal não encontrado',
          errors: ['Tipo de custo legal não encontrado']
        }, status: :not_found
      end

      def legal_cost_type_params
        params.expect(legal_cost_type: [:key, :name, :description, :category, :display_order, :active, :metadata])
      end

      def serialize_cost_type(type)
        {
          id: type.id,
          key: type.key,
          name: type.name,
          description: type.description,
          category: type.category,
          display_order: type.display_order,
          active: type.active,
          is_system: type.is_system,
          team_id: type.team_id,
          editable: type.editable?,
          deletable: type.deletable?,
          metadata: type.metadata,
          created_at: type.created_at,
          updated_at: type.updated_at
        }
      end
    end
  end
end
