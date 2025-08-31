# frozen_string_literal: true

module Api
  module V1
    class LegalCostsController < BackofficeController
      before_action :set_honorary
      before_action :set_legal_cost, only: [:show, :update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def show
        serialized = LegalCostSerializer.new(@legal_cost).serializable_hash

        render json: {
          success: true,
          message: 'Custos legais encontrados com sucesso',
          data: serialized[:data]
        }, status: :ok
      end

      def create
        legal_cost = @honorary.build_legal_cost(legal_cost_params)

        if legal_cost.save
          serialized = LegalCostSerializer.new(legal_cost).serializable_hash

          render json: {
            success: true,
            message: 'Custos legais criados com sucesso',
            data: serialized[:data]
          }, status: :created
        else
          error_messages = legal_cost.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao criar custos legais',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @legal_cost.update(legal_cost_params)
          serialized = LegalCostSerializer.new(@legal_cost).serializable_hash

          render json: {
            success: true,
            message: 'Custos legais atualizados com sucesso',
            data: serialized[:data]
          }, status: :ok
        else
          error_messages = @legal_cost.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao atualizar custos legais',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if @legal_cost.destroy
          render json: {
            success: true,
            message: 'Custos legais excluídos com sucesso',
            data: nil
          }, status: :ok
        else
          error_messages = @legal_cost.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao excluir custos legais',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      # Custom endpoints
      def summary
        legal_cost = @honorary.legal_cost

        unless legal_cost
          return render json: {
            success: false,
            message: 'Custos legais não encontrados',
            errors: ['Custos legais não encontrados para este honorário']
          }, status: :not_found
        end

        render json: {
          success: true,
          message: 'Resumo de custos legais obtido com sucesso',
          data: legal_cost.summary.merge(
            overdue_count: legal_cost.overdue_entries.count,
            upcoming_count: legal_cost.upcoming_entries.count,
            entries_by_type: legal_cost.entries.group(:cost_type).count
          )
        }, status: :ok
      end

      def overdue_entries
        legal_cost = @honorary.legal_cost

        unless legal_cost
          return render json: {
            success: false,
            message: 'Custos legais não encontrados',
            errors: ['Custos legais não encontrados para este honorário']
          }, status: :not_found
        end

        entries = legal_cost.overdue_entries.order(:due_date)
        serialized = LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount)
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Lançamentos vencidos obtidos com sucesso',
          data: serialized[:data],
          meta: serialized[:meta]
        }, status: :ok
      end

      def upcoming_entries
        legal_cost = @honorary.legal_cost
        days = params[:days]&.to_i || 30

        unless legal_cost
          return render json: {
            success: false,
            message: 'Custos legais não encontrados',
            errors: ['Custos legais não encontrados para este honorário']
          }, status: :not_found
        end

        entries = legal_cost.upcoming_entries(days).order(:due_date)
        serialized = LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount),
            days_ahead: days
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Próximos lançamentos obtidos com sucesso',
          data: serialized[:data],
          meta: serialized[:meta]
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
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Registro não encontrado',
          errors: ['Work, procedimento ou honorário não encontrado']
        }, status: :not_found
      end

      def set_legal_cost
        @legal_cost = @honorary.legal_cost
        raise ActiveRecord::RecordNotFound unless @legal_cost
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Custos legais não encontrados',
          errors: ['Custos legais não encontrados para este honorário']
        }, status: :not_found
      end

      def legal_cost_params
        params.expect(
          legal_cost: [:client_responsible,
                       :include_in_invoices,
                       :admin_fee_percentage]
        )
      end

      def perform_authorization
        authorize LegalCost
      end
    end
  end
end
