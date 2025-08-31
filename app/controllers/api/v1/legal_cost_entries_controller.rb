# frozen_string_literal: true

module Api
  module V1
    class LegalCostEntriesController < BackofficeController
      before_action :set_legal_cost
      before_action :set_entry, only: [:show, :update, :destroy, :mark_as_paid, :mark_as_unpaid]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        entries = @legal_cost.entries.includes(:legal_cost)

        entries = apply_filters(entries)
        entries = entries.order(created_at: :desc)

        serialized = LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount),
            paid_amount: entries.paid.sum(:amount),
            pending_amount: entries.pending.sum(:amount)
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Lançamentos de custos legais listados com sucesso',
          data: serialized[:data],
          meta: serialized[:meta]
        }, status: :ok
      end

      def show
        serialized = LegalCostEntrySerializer.new(@entry).serializable_hash

        render json: {
          success: true,
          message: 'Lançamento de custo legal encontrado com sucesso',
          data: serialized[:data]
        }, status: :ok
      end

      def create
        # Create entry directly with all params - the model handles cost_type via legal_cost_type_id
        entry = @legal_cost.entries.build(entry_params)

        if entry.save
          serialized = LegalCostEntrySerializer.new(entry).serializable_hash

          render json: {
            success: true,
            message: 'Lançamento de custo legal criado com sucesso',
            data: serialized[:data]
          }, status: :created
        else
          error_messages = entry.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao criar lançamento de custo legal',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @entry.update(entry_params)
          serialized = LegalCostEntrySerializer.new(@entry).serializable_hash

          render json: {
            success: true,
            message: 'Lançamento de custo legal atualizado com sucesso',
            data: serialized[:data]
          }, status: :ok
        else
          error_messages = @entry.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao atualizar lançamento de custo legal',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if @entry.destroy
          render json: {
            success: true,
            message: 'Lançamento de custo legal excluído com sucesso',
            data: nil
          }, status: :ok
        else
          error_messages = @entry.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first || 'Erro ao excluir lançamento de custo legal',
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      # Custom endpoints
      def mark_as_paid
        @entry.mark_as_paid!(
          payment_date: params[:payment_date] || Date.current,
          receipt: params[:receipt_number],
          method: params[:payment_method]
        )

        serialized = LegalCostEntrySerializer.new(@entry).serializable_hash

        render json: {
          success: true,
          message: 'Lançamento marcado como pago com sucesso',
          data: serialized[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: 'Erro ao marcar lançamento como pago',
          errors: [e.message]
        }, status: :unprocessable_entity
      end

      def mark_as_unpaid
        @entry.mark_as_unpaid!

        serialized = LegalCostEntrySerializer.new(@entry).serializable_hash

        render json: {
          success: true,
          message: 'Lançamento marcado como não pago com sucesso',
          data: serialized[:data]
        }, status: :ok
      rescue StandardError => e
        render json: {
          success: false,
          message: 'Erro ao marcar lançamento como não pago',
          errors: [e.message]
        }, status: :unprocessable_entity
      end

      def batch_create
        entries = []
        errors = []

        params[:entries].each do |entry_params|
          entry = @legal_cost.entries.build(entry_params.permit(permitted_params))

          if entry.save
            entries << entry
          else
            errors << { entry: entry_params[:name], errors: entry.errors.full_messages }
          end
        end

        if errors.empty?
          serialized = LegalCostEntrySerializer.new(entries).serializable_hash

          render json: {
            success: true,
            message: "#{entries.count} lançamento(s) criado(s) com sucesso",
            data: serialized[:data]
          }, status: :created
        else
          render json: {
            success: false,
            message: "Erro ao criar lançamentos em lote. #{entries.count} criado(s), #{errors.count} falharam",
            data: {
              created: entries.count,
              failed: errors.count
            },
            errors: errors
          }, status: :unprocessable_entity
        end
      end

      def by_type
        entries_by_type = @legal_cost.entries.group(:cost_type).sum(:amount)

        formatted_data = entries_by_type.map do |type, amount|
          {
            type: type,
            display_name: LegalCostEntry::BRAZILIAN_COST_TYPES[type.to_sym],
            amount: amount,
            count: @legal_cost.entries.where(cost_type: type).count
          }
        end

        render json: {
          success: true,
          message: 'Lançamentos agrupados por tipo obtidos com sucesso',
          data: formatted_data
        }, status: :ok
      end

      private

      def set_legal_cost
        work = team_scoped(Work).find(params[:work_id])
        if params[:procedure_id].present?
          procedure = work.procedures.find(params[:procedure_id])
          honorary = procedure.honoraries.find(params[:honorary_id])
        else
          honorary = work.honoraries.find(params[:honorary_id])
        end

        @legal_cost = honorary.legal_cost
        raise ActiveRecord::RecordNotFound unless @legal_cost
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Custos legais não encontrados',
          errors: ['Custos legais não encontrados para este honorário']
        }, status: :not_found
      end

      def set_entry
        @entry = @legal_cost.entries.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Lançamento de custo legal não encontrado',
          errors: ['Lançamento de custo legal não encontrado']
        }, status: :not_found
      end

      def entry_params
        params.expect(legal_cost_entry: permitted_params)
      end

      def permitted_params
        [
          :legal_cost_type_id,
          :cost_type,
          :name,
          :description,
          :amount,
          :estimated,
          :paid,
          :due_date,
          :payment_date,
          :receipt_number,
          :payment_method,
          { metadata: {} }
        ]
      end

      def apply_filters(entries)
        entries = entries.where(cost_type: params[:cost_type]) if params[:cost_type].present?
        entries = entries.where(paid: params[:paid] == 'true') if params[:paid].present?
        entries = entries.where(estimated: params[:estimated] == 'true') if params[:estimated].present?
        entries = entries.overdue if params[:overdue] == 'true'
        entries = entries.upcoming if params[:upcoming] == 'true'
        entries
      end

      def perform_authorization
        authorize LegalCostEntry
      end
    end
  end
end
