# frozen_string_literal: true

module Api
  module V1
    class LegalCostsController < BackofficeController
      before_action :set_honorary
      before_action :set_legal_cost, only: [:show, :update, :destroy]
      before_action :perform_authorization

      after_action :verify_authorized

      def show
        render json: LegalCostSerializer.new(
          @legal_cost,
          include: [:entries]
        ), status: :ok
      end

      def create
        legal_cost = @honorary.build_legal_cost(legal_cost_params)

        if legal_cost.save
          render json: LegalCostSerializer.new(legal_cost), status: :created
        else
          render json: { errors: legal_cost.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @legal_cost.update(legal_cost_params)
          render json: LegalCostSerializer.new(@legal_cost), status: :ok
        else
          render json: { errors: @legal_cost.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @legal_cost.destroy
        head :no_content
      end

      # Custom endpoints
      def summary
        legal_cost = @honorary.legal_cost

        return render json: { error: 'No legal cost found' }, status: :not_found unless legal_cost

        render json: {
          data: legal_cost.summary.merge(
            overdue_count: legal_cost.overdue_entries.count,
            upcoming_count: legal_cost.upcoming_entries.count,
            entries_by_type: legal_cost.entries.group(:cost_type).count
          )
        }, status: :ok
      end

      def overdue_entries
        legal_cost = @honorary.legal_cost

        return render json: { error: 'No legal cost found' }, status: :not_found unless legal_cost

        entries = legal_cost.overdue_entries.order(:due_date)

        render json: LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount)
          }
        ), status: :ok
      end

      def upcoming_entries
        legal_cost = @honorary.legal_cost
        days = params[:days]&.to_i || 30

        return render json: { error: 'No legal cost found' }, status: :not_found unless legal_cost

        entries = legal_cost.upcoming_entries(days).order(:due_date)

        render json: LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount),
            days_ahead: days
          }
        ), status: :ok
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

      def set_legal_cost
        @legal_cost = @honorary.legal_cost
        raise ActiveRecord::RecordNotFound unless @legal_cost
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
