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

        render json: LegalCostEntrySerializer.new(
          entries,
          meta: {
            total_count: entries.count,
            total_amount: entries.sum(:amount),
            paid_amount: entries.paid.sum(:amount),
            pending_amount: entries.pending.sum(:amount)
          }
        ), status: :ok
      end

      def show
        render json: LegalCostEntrySerializer.new(@entry), status: :ok
      end

      def create
        entry = @legal_cost.add_entry(
          params[:entry][:cost_type],
          params[:entry][:name],
          params[:entry][:amount],
          entry_params.except(:cost_type, :name, :amount)
        )

        if entry.persisted?
          render json: LegalCostEntrySerializer.new(entry), status: :created
        else
          render json: { errors: entry.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @entry.update(entry_params)
          render json: LegalCostEntrySerializer.new(@entry), status: :ok
        else
          render json: { errors: @entry.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @entry.destroy
        head :no_content
      end

      # Custom endpoints
      def mark_as_paid
        @entry.mark_as_paid!(
          payment_date: params[:payment_date] || Date.current,
          receipt: params[:receipt_number],
          method: params[:payment_method]
        )

        render json: LegalCostEntrySerializer.new(@entry), status: :ok
      end

      def mark_as_unpaid
        @entry.mark_as_unpaid!
        render json: LegalCostEntrySerializer.new(@entry), status: :ok
      end

      def batch_create
        entries, errors = process_batch_entries
        render_batch_response(entries, errors)
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

        render json: { data: formatted_data }, status: :ok
      end

      private

      def set_legal_cost
        work = team_scoped(Work).find(params[:work_id])
        honorary = find_honorary(work)
        @legal_cost = honorary.legal_cost
        raise ActiveRecord::RecordNotFound unless @legal_cost
      end

      def set_entry
        @entry = @legal_cost.entries.find(params[:id])
      end

      def entry_params
        params.expect(entry: [permitted_params])
      end

      def permitted_params
        [
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
        entries = apply_type_filter(entries)
        entries = apply_status_filters(entries)
        apply_date_filters(entries)
      end

      def perform_authorization
        authorize LegalCostEntry
      end

      def process_batch_entries
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

        [entries, errors]
      end

      def render_batch_response(entries, errors)
        if errors.empty?
          render json: LegalCostEntrySerializer.new(entries), status: :created
        else
          render json: {
            created: entries.count,
            failed: errors.count,
            errors: errors
          }, status: :unprocessable_content
        end
      end

      def find_honorary(work)
        if params[:procedure_id].present?
          procedure = work.procedures.find(params[:procedure_id])
          procedure.honoraries.find(params[:honorary_id])
        else
          work.honoraries.find(params[:honorary_id])
        end
      end

      def apply_type_filter(entries)
        return entries if params[:cost_type].blank?

        entries.where(cost_type: params[:cost_type])
      end

      def apply_status_filters(entries)
        entries = entries.where(paid: params[:paid] == 'true') if params[:paid].present?
        entries = entries.where(estimated: params[:estimated] == 'true') if params[:estimated].present?
        entries
      end

      def apply_date_filters(entries)
        entries = entries.overdue if params[:overdue] == 'true'
        entries = entries.upcoming if params[:upcoming] == 'true'
        entries
      end
    end
  end
end
